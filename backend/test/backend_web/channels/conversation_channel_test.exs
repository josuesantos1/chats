defmodule BackendWeb.ConversationChannelTest do
  use ExUnit.Case, async: false
  import Phoenix.ChannelTest

  import Backend.AccountsFixtures
  import Backend.ConversationsFixtures

  alias BackendWeb.UserSocket
  alias Backend.Conversations

  @endpoint BackendWeb.Endpoint

  setup tags do
    Backend.DataCase.setup_sandbox(tags)
    :ok
  end

  describe "UserSocket.connect/3" do
    test "connects with valid user_id" do
      user = user_fixture()
      assert {:ok, socket} = connect(UserSocket, %{"user_id" => user.id})
      assert socket.assigns.current_user.id == user.id
    end

    test "rejects connection with invalid user_id" do
      assert :error = connect(UserSocket, %{"user_id" => Ecto.UUID.generate()})
    end

    test "rejects connection without user_id" do
      assert :error = connect(UserSocket, %{})
    end
  end

  describe "ConversationChannel join" do
    setup do
      user = user_fixture()
      conversation = conversation_fixture()

      {:ok, _} =
        Conversations.add_conversation_member(%{
          conversation_id: conversation.id,
          user_id: user.id
        })

      {:ok, socket} = connect(UserSocket, %{"user_id" => user.id})

      {:ok, socket: socket, user: user, conversation: conversation}
    end

    test "joins authorized conversation", %{socket: socket, conversation: conversation} do
      assert {:ok, _, _socket} =
               subscribe_and_join(socket, "conversation:#{conversation.id}", %{})
    end

    test "rejects join for unauthorized conversation", %{socket: socket} do
      other_conversation = conversation_fixture()

      assert {:error, %{reason: "unauthorized"}} =
               subscribe_and_join(socket, "conversation:#{other_conversation.id}", %{})
    end
  end

  describe "ConversationChannel handle_in send_message" do
    setup do
      user = user_fixture()
      conversation = conversation_fixture()

      {:ok, _} =
        Conversations.add_conversation_member(%{
          conversation_id: conversation.id,
          user_id: user.id
        })

      {:ok, socket} = connect(UserSocket, %{"user_id" => user.id})

      {:ok, _, socket} =
        subscribe_and_join(socket, "conversation:#{conversation.id}", %{})

      {:ok, socket: socket, user: user, conversation: conversation}
    end

    test "creates and broadcasts message", %{socket: socket, conversation: conversation} do
      ref =
        push(socket, "send_message", %{
          "conversation_id" => conversation.id,
          "content" => "hello world"
        })

      assert_reply ref, :ok, payload
      assert payload.content == "hello world"
      assert payload.conversation_id == conversation.id
    end

    test "returns error for invalid message content", %{
      socket: socket,
      conversation: conversation
    } do
      ref =
        push(socket, "send_message", %{
          "conversation_id" => conversation.id,
          "content" => nil
        })

      assert_reply ref, :error, %{errors: _errors}
    end
  end
end
