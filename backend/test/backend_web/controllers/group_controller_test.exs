defmodule BackendWeb.GroupControllerTest do
  use BackendWeb.ConnCase

  import Backend.ConversationsFixtures
  alias Backend.Groups
  alias Backend.Conversations
  alias Backend.Groups.Group

  @invalid_attrs %{name: nil}

  setup %{conn: conn, current_user: current_user} do
    conversation = conversation_fixture(%{type: "group"})

    create_attrs = %{
      name: "some name",
      creator_id: current_user.id,
      conversation_id: conversation.id
    }

    {:ok,
     conn: put_req_header(conn, "accept", "application/json"),
     create_attrs: create_attrs,
     conversation: conversation}
  end

  describe "index" do
    test "lists groups for current user (empty when no membership)", %{conn: conn} do
      conn = get(conn, ~p"/api/groups")
      assert json_response(conn, 200)["data"] == []
    end

    test "lists groups where current user is a member", %{
      conn: conn,
      current_user: current_user,
      create_attrs: create_attrs,
      conversation: conversation
    } do
      {:ok, group} = Groups.create_group(create_attrs)

      {:ok, _} =
        Conversations.add_conversation_member(%{
          conversation_id: conversation.id,
          user_id: current_user.id
        })

      conn = get(conn, ~p"/api/groups")
      data = json_response(conn, 200)["data"]
      assert Enum.any?(data, &(&1["id"] == group.id))
    end
  end

  describe "create group" do
    test "renders group when data is valid", %{conn: conn, create_attrs: create_attrs} do
      conn = post(conn, ~p"/api/groups", group: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/groups/#{id}")
      assert %{"id" => ^id, "name" => "some name"} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/groups", group: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update group" do
    setup [:create_group]

    test "renders group when data is valid", %{conn: conn, group: %Group{id: id} = group} do
      conn = put(conn, ~p"/api/groups/#{group}", group: %{name: "some updated name"})
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/groups/#{id}")
      assert %{"name" => "some updated name"} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = put(conn, ~p"/api/groups/#{group}", group: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete group" do
    setup [:create_group]

    test "deletes chosen group", %{conn: conn, group: group} do
      conn = delete(conn, ~p"/api/groups/#{group}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/groups/#{group}")
      end
    end
  end

  defp create_group(%{create_attrs: create_attrs}) do
    {:ok, group} = Groups.create_group(create_attrs)
    %{group: group}
  end
end
