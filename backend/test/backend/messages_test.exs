defmodule Backend.MessagesTest do
  use Backend.DataCase

  alias Backend.Messages

  describe "messages" do
    alias Backend.Messages.Message

    import Backend.MessagesFixtures
    import Backend.AccountsFixtures
    import Backend.ConversationsFixtures

    @invalid_attrs %{content: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Enum.any?(Messages.list_messages(), &(&1.id == message.id))
    end

    test "list_messages_by_conversation/1 returns messages for a conversation ordered by time" do
      user = user_fixture()
      conversation = conversation_fixture()

      {:ok, msg1} =
        Messages.create_message(%{
          content: "first",
          author_id: user.id,
          conversation_id: conversation.id
        })

      {:ok, msg2} =
        Messages.create_message(%{
          content: "second",
          author_id: user.id,
          conversation_id: conversation.id
        })

      result = Messages.list_messages_by_conversation(conversation.id)
      ids = Enum.map(result, & &1.id)
      assert msg1.id in ids
      assert msg2.id in ids
    end

    test "list_messages_by_conversation/1 excludes messages from other conversations" do
      user = user_fixture()
      conversation = conversation_fixture()
      other_conversation = conversation_fixture()

      {:ok, _} =
        Messages.create_message(%{
          content: "other",
          author_id: user.id,
          conversation_id: other_conversation.id
        })

      result = Messages.list_messages_by_conversation(conversation.id)
      assert result == []
    end

    test "get_last_messages/1 returns empty list for empty input" do
      assert Messages.get_last_messages([]) == []
    end

    test "get_last_messages/1 returns one message per conversation" do
      user = user_fixture()
      conv1 = conversation_fixture()
      conv2 = conversation_fixture()

      {:ok, _} =
        Messages.create_message(%{
          content: "first",
          author_id: user.id,
          conversation_id: conv1.id
        })

      {:ok, _} =
        Messages.create_message(%{
          content: "last in conv1",
          author_id: user.id,
          conversation_id: conv1.id
        })

      {:ok, _} =
        Messages.create_message(%{
          content: "in conv2",
          author_id: user.id,
          conversation_id: conv2.id
        })

      result = Messages.get_last_messages([conv1.id, conv2.id])
      assert length(result) == 2
      assert Enum.any?(result, &(&1.conversation_id == conv1.id))
      assert Enum.any?(result, &(&1.conversation_id == conv2.id))
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Messages.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      user = user_fixture()
      conversation = conversation_fixture()

      valid_attrs = %{
        content: "some content",
        author_id: user.id,
        conversation_id: conversation.id
      }

      assert {:ok, %Message{} = message} = Messages.create_message(valid_attrs)
      assert message.content == "some content"
      assert message.author_id == user.id
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Message{} = message} = Messages.update_message(message, update_attrs)
      assert message.content == "some updated content"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Messages.update_message(message, @invalid_attrs)
      assert message == Messages.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Messages.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Messages.change_message(message)
    end
  end
end
