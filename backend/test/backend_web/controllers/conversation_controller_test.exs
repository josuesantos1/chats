defmodule BackendWeb.ConversationControllerTest do
  use BackendWeb.ConnCase

  import Backend.ConversationsFixtures
  alias Backend.Conversations.Conversation

  @create_attrs %{type: "private"}
  @update_attrs %{type: "group"}
  @invalid_attrs %{type: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all conversations", %{conn: conn} do
      conn = get(conn, ~p"/api/conversations")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create conversation" do
    test "renders conversation when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/conversations", conversation: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/conversations/#{id}")

      assert %{"type" => "private"} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/conversations", conversation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update conversation" do
    setup [:create_conversation]

    test "renders conversation when data is valid", %{
      conn: conn,
      conversation: %Conversation{id: id} = conversation
    } do
      conn = put(conn, ~p"/api/conversations/#{conversation}", conversation: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/conversations/#{id}")

      assert %{"type" => "group"} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, conversation: conversation} do
      conn = put(conn, ~p"/api/conversations/#{conversation}", conversation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete conversation" do
    setup [:create_conversation]

    test "deletes chosen conversation", %{conn: conn, conversation: conversation} do
      conn = delete(conn, ~p"/api/conversations/#{conversation}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/conversations/#{conversation}")
      end
    end
  end

  defp create_conversation(_) do
    conversation = conversation_fixture()

    %{conversation: conversation}
  end
end
