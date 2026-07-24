defmodule BackendWeb.SessionController do
  use BackendWeb, :controller

  alias Backend.Accounts

  def create(conn, %{"username" => username, "password" => password}) do
    case Accounts.verify_credentials(username, password) do
      {:ok, user} ->
        conn
        |> json(%{
          data: %{
            id: user.id,
            name: user.name,
            email: user.email,
            username: user.username
          }
        })

      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid username or password"})
    end
  end
end
