defmodule RumblWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller

  alias Rumbl.Accounts
  alias RumblWeb.Router.Helpers, as: Routes

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    delete_session(conn, :user_id)
  end

  def login_by_email_and_pass(conn, email, given_pass) do
    case Accounts.authenticate_by_email_and_pass(email, given_pass) do
      {:ok, user}             -> {:ok, login(conn, user)}
      {:error, :unauthorized} -> {:error, :unauthorized, conn}
      {:error, :not_found}    -> {:error, :not_found, conn}
    end
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "Your must be logged in")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
