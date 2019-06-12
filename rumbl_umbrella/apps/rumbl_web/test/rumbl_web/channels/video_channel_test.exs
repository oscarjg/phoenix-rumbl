defmodule RumblWeb.Channels.VideoChannelTest do
  use RumblWeb.ChannelCase

  import RumblWeb.TestHelpers

  setup do
    user  = insert_user(name: "Gary")
    video = insert_video(user, title: "Testing")
    token = Phoenix.Token.sign(@endpoint, "user token", user.id)

    {:ok, socket} = connect(RumblWeb.UserSocket, %{"token" => token})

    {:ok, socket: socket, user: user, video: video}
  end

  test "inserting new annotations", %{socket: socket, video: video} do
    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})
    ref = push socket, "new_annotation", %{body: "the body", at: 0}
    assert_reply ref, :ok, %{}
    assert_broadcast "new_annotation", %{}
  end

  test "new annotation fires InfoSys", %{socket: socket, video: video}do
    insert_user(%{
      name: "Wolfram",
      username: "wolfram",
      credential: %{email: "wolfram@test", password: "supersecret"}
    })

    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})
    ref = push socket, "new_annotation", %{body: "1 + 1", at: 123}
    assert_reply ref, :ok, %{}
    assert_broadcast "new_annotation", %{body: "1 + 1", at: 123}
    assert_broadcast "new_annotation", %{body: "2", at: 123}
  end
end