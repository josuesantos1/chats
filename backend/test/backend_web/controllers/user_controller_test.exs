defmodule BackendWeb.UserControllerTest do
  use BackendWeb.ConnCase

  import Backend.AccountsFixtures
  alias Backend.Accounts.User

  @create_attrs %{
    name: "some name",
    username: "create_user_test",
    email: "create_user@test.com",
    password: "password123"
  }
  @update_attrs %{
    name: "some updated name",
    username: "updated_user_test",
    email: "updated_user@test.com"
  }
  @invalid_attrs %{id: nil, name: nil, username: nil, email: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn, current_user: current_user} do
      conn = get(conn, ~p"/api/users")
      data = json_response(conn, 200)["data"]
      assert Enum.any?(data, &(&1["id"] == current_user.id))
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "email" => "create_user@test.com",
               "name" => "some name",
               "username" => "create_user_test"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show user" do
    setup [:create_user]

    test "renders user by id", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/users/#{user.id}")
      assert %{"id" => id} = json_response(conn, 200)["data"]
      assert id == user.id
    end
  end

  describe "get user by username" do
    setup [:create_user]

    test "renders user when username exists", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/users/#{user.username}/username/")
      assert %{"id" => id} = json_response(conn, 200)["data"]
      assert id == user.id
    end

    test "returns 404 when username does not exist", %{conn: conn} do
      conn = get(conn, ~p"/api/users/nonexistent/username/")
      assert json_response(conn, 404)["error"] != nil
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "email" => "updated_user@test.com",
               "name" => "some updated name",
               "username" => "updated_user_test"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/api/users/#{user}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/users/#{user}")
      end
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
