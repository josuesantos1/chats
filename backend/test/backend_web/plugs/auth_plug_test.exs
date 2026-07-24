defmodule BackendWeb.Plugs.AuthPlugTest do
  use BackendWeb.ConnCase

  import Backend.AccountsFixtures

  setup %{} do
    {:ok, conn: build_conn() |> put_req_header("accept", "application/json")}
  end

  describe "call/2" do
    test "assigns current_user when x-user-id header is valid", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> put_req_header("x-user-id", user.id)
        |> get(~p"/api/users")

      assert json_response(conn, 200)
    end

    test "assigns current_user when authorization header is used instead", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> put_req_header("authorization", user.id)
        |> get(~p"/api/users")

      assert json_response(conn, 200)
    end

    test "returns 401 when no auth header is present", %{conn: conn} do
      conn = get(conn, ~p"/api/users")
      assert json_response(conn, 401)["error"] != nil
    end

    test "returns 401 when user_id does not match any user", %{conn: conn} do
      conn =
        conn
        |> put_req_header("x-user-id", Ecto.UUID.generate())
        |> get(~p"/api/users")

      assert json_response(conn, 401)["error"] != nil
    end
  end
end
