defmodule BackendWeb.MessageControllerTest do
  use BackendWeb.ConnCase

  import Backend.ConversationsFixtures
  alias Backend.Messages.Message

  @invalid_attrs %{content: nil}

  setup %{conn: conn, current_user: current_user} do
    conversation = conversation_fixture()

    create_attrs = %{
      content: "some content",
      author_id: current_user.id,
      conversation_id: conversation.id
    }

    {:ok,
     conn: put_req_header(conn, "accept", "application/json"),
     create_attrs: create_attrs,
     conversation: conversation}
  end

  describe "by_conversation" do
    test "lists messages for a conversation", %{
      conn: conn,
      conversation: conversation,
      create_attrs: create_attrs
    } do
      Backend.Messages.create_message(create_attrs)
      conn = get(conn, ~p"/api/conversations/#{conversation.id}/messages")
      data = json_response(conn, 200)["data"]
      assert length(data) == 1
      assert hd(data)["content"] == "some content"
    end

    test "returns empty list for conversation with no messages", %{
      conn: conn,
      conversation: conversation
    } do
      conn = get(conn, ~p"/api/conversations/#{conversation.id}/messages")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create message" do
    test "renders message when data is valid", %{conn: conn, create_attrs: create_attrs} do
      conn = post(conn, ~p"/api/messages", message: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/messages/#{id}")
      assert %{"id" => ^id, "content" => "some content"} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/messages", message: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update message" do
    setup [:create_message]

    test "renders message when data is valid", %{conn: conn, message: %Message{id: id} = message} do
      conn = put(conn, ~p"/api/messages/#{message}", message: %{content: "some updated content"})
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/messages/#{id}")
      assert %{"content" => "some updated content"} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, message: message} do
      conn = put(conn, ~p"/api/messages/#{message}", message: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete message" do
    setup [:create_message]

    test "deletes chosen message", %{conn: conn, message: message} do
      conn = delete(conn, ~p"/api/messages/#{message}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/messages/#{message}")
      end
    end
  end

  defp create_message(%{create_attrs: create_attrs}) do
    {:ok, message} = Backend.Messages.create_message(create_attrs)
    %{message: message}
  end
end
