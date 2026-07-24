defmodule BackendWeb.SessionControllerTest do
  use BackendWeb.ConnCase

  import Backend.AccountsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create session" do
    test "returns user data with valid credentials", %{conn: conn} do
      user = user_fixture()

      conn =
        post(conn, ~p"/api/sessions", %{username: user.username, password: "password123"})

      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == user.id
      assert data["username"] == user.username
      assert data["email"] == user.email
      assert data["name"] == user.name
    end

    test "returns 401 with invalid password", %{conn: conn} do
      user = user_fixture()

      conn =
        post(conn, ~p"/api/sessions", %{username: user.username, password: "wrongpassword"})

      assert json_response(conn, 401)["error"] != nil
    end

    test "returns 401 with unknown username", %{conn: conn} do
      conn =
        post(conn, ~p"/api/sessions", %{username: "nonexistent", password: "password123"})

      assert json_response(conn, 401)["error"] != nil
    end
  end
end
