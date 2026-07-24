defmodule BackendWeb.ConversationControllerTest do
  use BackendWeb.ConnCase

  import Backend.ConversationsFixtures
  import Backend.AccountsFixtures
  alias Backend.Conversations
  alias Backend.Conversations.Conversation

  @create_attrs %{type: "private"}
  @update_attrs %{type: "group"}
  @invalid_attrs %{type: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists conversations for current user", %{conn: conn} do
      conn = get(conn, ~p"/api/conversations")
      assert json_response(conn, 200)["data"] == []
    end

    test "lists only conversations where current user is a member", %{
      conn: conn,
      current_user: current_user
    } do
      conversation = conversation_fixture()

      {:ok, _} =
        Conversations.add_conversation_member(%{
          conversation_id: conversation.id,
          user_id: current_user.id
        })

      conn = get(conn, ~p"/api/conversations")
      data = json_response(conn, 200)["data"]
      assert Enum.any?(data, &(&1["id"] == conversation.id))
    end

    test "includes last_message when conversation has messages", %{
      conn: conn,
      current_user: current_user
    } do
      conversation = conversation_fixture()

      {:ok, _} =
        Conversations.add_conversation_member(%{
          conversation_id: conversation.id,
          user_id: current_user.id
        })

      {:ok, _} =
        Backend.Messages.create_message(%{
          content: "last message content",
          author_id: current_user.id,
          conversation_id: conversation.id
        })

      conn = get(conn, ~p"/api/conversations")
      data = json_response(conn, 200)["data"]
      conv = Enum.find(data, &(&1["id"] == conversation.id))
      assert conv["last_message"]["content"] == "last message content"
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

  describe "members" do
    setup [:create_conversation]

    test "lists members of a conversation", %{conn: conn, conversation: conversation} do
      user = user_fixture()

      {:ok, _} =
        Conversations.add_conversation_member(%{
          conversation_id: conversation.id,
          user_id: user.id
        })

      conn = get(conn, ~p"/api/conversations/#{conversation.id}/members")
      data = json_response(conn, 200)["data"]
      assert Enum.any?(data, &(&1["user_id"] == user.id))
    end

    test "returns empty list when no members", %{conn: conn, conversation: conversation} do
      conn = get(conn, ~p"/api/conversations/#{conversation.id}/members")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "add_member" do
    setup [:create_conversation]

    test "adds a member to a conversation", %{conn: conn, conversation: conversation} do
      user = user_fixture()

      conn =
        post(conn, ~p"/api/conversations/#{conversation.id}/members", member: %{user_id: user.id})

      data = json_response(conn, 200)["data"]
      assert Enum.any?(data, &(&1["user_id"] == user.id))
    end

    test "returns error when member data is invalid", %{conn: conn, conversation: conversation} do
      conn =
        post(conn, ~p"/api/conversations/#{conversation.id}/members", member: %{user_id: nil})

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_conversation(_) do
    conversation = conversation_fixture()
    %{conversation: conversation}
  end
end
