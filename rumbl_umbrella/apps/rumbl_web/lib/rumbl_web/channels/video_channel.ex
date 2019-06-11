defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  alias Rumbl.{
    Multimedia,
    Accounts
  }

  def join("videos:" <> video_id, params, socket) do
    video    = Multimedia.get_video!(String.to_integer(video_id))
    since_id = params["last_seen_id"] || 0

    annotations =
      video
      |> Multimedia.list_annotations(since_id)
      |> Phoenix.View.render_many(RumblWeb.AnnotationView, "annotation.json")

    {:ok, %{annotations: annotations}, assign(socket, :video_id, String.to_integer(video_id))}
  end

  def handle_in(event, params, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_annotation", params, user, socket) do
    case Multimedia.annotate_video(user, socket.assigns.video_id, params) do
      {:ok, annotation} ->
        broadcast_annotation(socket, annotation)

        Task.start_link(fn ->
          compute_additional_annotation(socket, annotation)
        end)

        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  def handle_info(:ping, socket) do
    count = socket.assigns[:count] || 1
    push(socket, "ping", %{count: count})
    {:noreply, assign(socket, :count, count + 1)}
  end

  defp compute_additional_annotation(socket, annotation) do
    for result <- InfoSys.compute(annotation.body, limit: 1, timeout: 10_000) do
      backend_user = Accounts.get_user_by(username: result.backend.name())
      attrs = %{
        url: result.url,
        body: result.text,
        at: annotation.at
      }

      case Multimedia.annotate_video(backend_user, annotation.video_id, attrs) do
        {:ok, info_ann} ->
          broadcast_annotation(socket, info_ann)
        {:error, _changeset} ->
          :ignore
      end

    end
  end

  defp broadcast_annotation(socket, annotation) do
    broadcast!(
      socket,
      "new_annotation",
      Phoenix.View.render_one(
        annotation,
        RumblWeb.AnnotationView,
        "annotation.json"
      )
    )
  end
end