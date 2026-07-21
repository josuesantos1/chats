defmodule BackendWeb.MessageControllerTest do
  use BackendWeb.ConnCase

  import Backend.MessagesFixtures
  import Backend.AccountsFixtures
  import Backend.ConversationsFixtures
  alias Backend.Messages.Message

  @invalid_attrs %{content: nil}

  setup %{conn: conn} do
    user = user_fixture()
    conversation = conversation_fixture()

    create_attrs = %{content: "some content", author_id: user.id, conversation_id: conversation.id}

    {:ok, conn: put_req_header(conn, "accept", "application/json"), create_attrs: create_attrs}
  end

  describe "index" do
    test "lists all messages", %{conn: conn} do
      conn = get(conn, ~p"/api/messages")
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

  defp create_message(_) do
    message = message_fixture()
    %{message: message}
  end
end
