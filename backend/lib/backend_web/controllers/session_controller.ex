defmodule BackendWeb.SessionController do
  use BackendWeb, :controller

  alias Backend.Accounts

  def create(conn, %{"username" => username}) do
    case Accounts.get_user_by_username(username) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "User not found"})

      user ->
        conn
        |> json(%{
          data: %{
            id: user.id,
            name: user.name,
            email: user.email,
            username: user.username
          }
        })
    end
  end
end
