defmodule RumblWeb.VideoControllerTest do
  use RumblWeb.ConnCase

  describe "with a logged-out user" do
    test "requires user auth on all actions", %{conn: conn} do
      routes = [
        get(conn, Routes.video_path(conn, :index)),
        get(conn, Routes.video_path(conn, :new)),
        get(conn, Routes.video_path(conn, :show, 123)),
        get(conn, Routes.video_path(conn, :edit, 123)),
        post(conn, Routes.video_path(conn, :create, %{})),
        put(conn, Routes.video_path(conn, :update, 123, %{})),
        delete(conn, Routes.video_path(conn, :delete, 123)),
      ]

      Enum.map(routes, fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end)
    end
  end


  describe "with a logged-in user" do

    @create_attr %{title: "new video", description: "Some desc", url: "https://foo.com"}
    @invalid_attr %{title: nil, description: nil, url: "https://foo.com"}

    defp count_videos() do
      Enum.count(Rumbl.Multimedia.list_videos())
    end

    setup %{conn: conn, login_as: username} do
      user = user_fixture(username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "my_username"
    test "list all user videos on index", %{conn: conn, user: user} do
      user_video  = video_fixture(user)
      other_video = video_fixture(user_fixture(%{username: "other"}), %{title: "Other video title"})

      conn = get(conn, Routes.video_path(conn, :index))

      assert html_response(conn, 200) =~ ~r/Listing Videos/
      assert String.contains?(conn.resp_body, user_video.title)
      refute String.contains?(conn.resp_body, other_video.title)
    end

    @tag login_as: "my_username"
    test "create a video", %{conn: conn, user: user} do
      create_conn = post(conn, Routes.video_path(conn, :create, %{video: @create_attr}))

      assert %{id: id} = redirected_params(create_conn)
      assert redirected_to(create_conn) == Routes.video_path(conn, :show, id)

      conn  = get(conn, Routes.video_path(conn, :show, id))
      video = Rumbl.Multimedia.get_video!(id)

      assert html_response(conn, 200) =~ "Show Video"
      assert video.user_id == user.id
    end

    @tag login_as: "my_username"
    test "create with invalid attrs should display errors", %{conn: conn} do
      videos_count = count_videos()
      create_conn  = post(conn, Routes.video_path(conn, :create, %{video: @invalid_attr}))

      assert html_response(create_conn, 200) =~ "check the errors"
      assert videos_count == count_videos()
    end

    @tag login_as: "my_username"
    test "videos from other owner must return not found", %{conn: conn, user: _user} do
      other_video = video_fixture(user_fixture(%{username: "other"}), %{title: "Other video title"})

      assert_error_sent :not_found, fn -> get(conn, Routes.video_path(conn, :show, other_video)) end
      assert_error_sent :not_found, fn -> get(conn, Routes.video_path(conn, :edit, other_video)) end
      assert_error_sent :not_found, fn -> put(conn, Routes.video_path(conn, :update, other_video, %{video: @create_attr})) end
      assert_error_sent :not_found, fn -> delete(conn, Routes.video_path(conn, :delete, other_video)) end
    end
  end
end
