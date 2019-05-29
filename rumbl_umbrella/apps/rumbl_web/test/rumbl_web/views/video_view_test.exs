defmodule RumblWeb.VideoViewTest do
  use RumblWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View
  alias  RumblWeb.VideoView
  alias  Rumbl.Multimedia.Video
  alias  Rumbl.Multimedia.Category
  alias  Rumbl.Multimedia
  alias  Rumbl.Accounts.User

  test "renders video lists", %{conn: conn} do
    videos = [
      %Video{id: 1, title: "Video 1", description: "Video desc 1", url: "https://video-1.com"},
      %Video{id: 2, title: "Video 2", description: "Video desc 2", url: "https://video-2.com"},
      %Video{id: 3, title: "Video 2", description: "Video desc 2", url: "https://video-3.com"},
    ]

    content = render_to_string(VideoView, "index.html", [conn: conn, videos: videos])

    assert string_contains(content, "Listing Videos")

    Enum.each(videos, fn video ->
      assert string_contains(content, Routes.video_path(conn, :show, video))
      assert string_contains(content, Routes.video_path(conn, :edit, video))
      assert string_contains(content, Routes.watch_path(conn, :show, video))
      assert string_contains(content, video.title)
    end)
  end

  test "new video form", %{conn: conn} do
    categories = [
      %Category{id: 1, name: "Category-1"},
      %Category{id: 2, name: "Category-2"},
      %Category{id: 3, name: "Category-3"},
    ]

    changeset = Multimedia.change_video(%User{}, %Video{})

    content = render_to_string(VideoView, "new.html", [conn: conn, changeset: changeset, categories: categories])

    assert string_contains(content, "New Video")

    Enum.each(categories, fn category ->
      assert string_contains(content, category.name)
    end)
  end

  defp string_contains(string, contains) do
    String.contains?(string, contains)
  end
end
