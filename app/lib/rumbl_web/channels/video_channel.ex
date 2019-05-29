defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  alias Rumbl.{
    Multimedia,
    Accounts
  }

  def join("videos:" <> video_id, _params, socket) do
    video = Multimedia.get_video!(String.to_integer(video_id))

    annotations =
      video
      |> Multimedia.list_annotations()
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
        broadcast!(socket, "new_annotation", RumblWeb.AnnotationView.render("annotation.json", annotation))
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
end