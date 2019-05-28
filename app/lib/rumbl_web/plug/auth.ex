defmodule RumblWeb.Plug.Auth do
  @moduledoc false

  import Plug.Conn
  alias  Rumbl.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        put_current_user_and_user_token(conn, user)

      user = user_id && Accounts.get_user(user_id) ->
        put_current_user_and_user_token(conn, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def put_current_user_and_user_token(conn, user) do
    token = Phoenix.Token.sign(conn, "user token", %{id: user.id, username: user.username})

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end
end
