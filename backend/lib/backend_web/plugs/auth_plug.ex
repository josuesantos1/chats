defmodule BackendWeb.Plugs.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias Backend.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "x-user-id") do
      [user_id | _] ->
        case Accounts.get_user(user_id) do
          nil ->
            conn
            |> put_status(:unauthorized)
            |> json(%{error: "Unauthorized"})
            |> halt()

          user ->
            assign(conn, :current_user, user)
        end

      [] ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Missing x-user-id header"})
        |> halt()
    end
  end
end
