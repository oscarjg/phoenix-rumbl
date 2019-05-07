defmodule RumblWeb.UserController do
  @moduledoc """
    User controller
  """

  use RumblWeb, :controller

  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

  def index(conn, _params) do
    render(conn, "index.html", users: Accounts.list_users())
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", user: Accounts.get_user(id))
  end

  def new(conn, _params) do
    changeset = Accounts.registration_changeset_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "#{user.username} has been created!")
        |> redirect(to: Routes.user_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect changeset
        render(conn, "new.html", changeset: changeset)
    end
  end
end
