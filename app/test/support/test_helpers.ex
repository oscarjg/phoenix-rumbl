defmodule Rumbl.TestHelpers do
  alias Rumbl.{
      Accounts,
      Multimedia
    }

  def user_fixture(attr \\ %{}) do
    username = "user#{System.unique_integer([:positive])}"

    {:ok, user} =
      attr
      |> Enum.into(%{
        name: "Some user",
        username: username,
        credential: %{
          email: attr[:email] || "#{username}@example.com",
          password: attr[:password] || "super_secret",
        }
      })
      |> Accounts.register_user()

      user
  end


  def video_fixture(%Accounts.User{} = user, attr \\ %{}) do
    attr = Enum.into(
      attr,
      %{
        title: "A title",
        description: "Some lorem ipsum description",
        url: "http://example.com"
      }
    )

    {:ok, video} = Multimedia.create_video(user, attr)

    video
  end
end