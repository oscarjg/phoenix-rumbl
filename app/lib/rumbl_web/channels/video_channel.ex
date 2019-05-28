defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  def join("videos:" <> _video_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("new_annotation", params, socket) do
    case socket.assigns[:user] do
      %{username: username} ->
        broadcast!(socket, "new_annotation", %{
          user: %{username: username},
          body: params["body"],
          at: params["at"],
        })

        {:reply, :ok, socket}
      _ ->
        {:noreply, :error, socket}
    end
  end

  def handle_info(:ping, socket) do
    count = socket.assigns[:count] || 1
    push(socket, "ping", %{count: count})
    {:noreply, assign(socket, :count, count + 1)}
  end
end