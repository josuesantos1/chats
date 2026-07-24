defmodule Backend.ConversationsTest do
  use Backend.DataCase

  alias Backend.Conversations

  describe "conversations" do
    alias Backend.Conversations.Conversation

    import Backend.ConversationsFixtures
    import Backend.AccountsFixtures

    @invalid_attrs %{type: nil}

    test "list_conversations/0 returns all conversations" do
      conversation = conversation_fixture()
      assert Enum.any?(Conversations.list_conversations(), &(&1.id == conversation.id))
    end

    test "list_conversations_for_user/1 returns conversations where user is a member" do
      user = user_fixture()
      conversation = conversation_fixture()

      {:ok, _} =
        Conversations.add_conversation_member(%{
          conversation_id: conversation.id,
          user_id: user.id
        })

      result = Conversations.list_conversations_for_user(user.id)
      assert Enum.any?(result, &(&1.id == conversation.id))
    end

    test "list_conversations_for_user/1 excludes conversations the user is not a member of" do
      user = user_fixture()
      _other_conversation = conversation_fixture()

      result = Conversations.list_conversations_for_user(user.id)
      assert result == []
    end

    test "list_conversation_members/1 returns all members of a conversation" do
      user = user_fixture()
      conversation = conversation_fixture()

      {:ok, member} =
        Conversations.add_conversation_member(%{
          conversation_id: conversation.id,
          user_id: user.id
        })

      result = Conversations.list_conversation_members(conversation.id)
      assert Enum.any?(result, &(&1.id == member.id))
    end

    test "is_member?/2 returns true when user is a member" do
      user = user_fixture()
      conversation = conversation_fixture()

      {:ok, _} =
        Conversations.add_conversation_member(%{
          conversation_id: conversation.id,
          user_id: user.id
        })

      assert Conversations.is_member?(conversation.id, user.id) == true
    end

    test "is_member?/2 returns false when user is not a member" do
      user = user_fixture()
      conversation = conversation_fixture()
      assert Conversations.is_member?(conversation.id, user.id) == false
    end

    test "add_conversation_member/1 adds a member to a conversation" do
      user = user_fixture()
      conversation = conversation_fixture()

      assert {:ok, member} =
               Conversations.add_conversation_member(%{
                 conversation_id: conversation.id,
                 user_id: user.id
               })

      assert member.user_id == user.id
      assert member.conversation_id == conversation.id
    end

    test "add_conversation_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Conversations.add_conversation_member(%{})
    end

    test "get_conversation!/1 returns the conversation with given id" do
      conversation = conversation_fixture()
      assert Conversations.get_conversation!(conversation.id) == conversation
    end

    test "create_conversation/1 with valid data creates a conversation" do
      valid_attrs = %{type: "private"}

      assert {:ok, %Conversation{} = conversation} =
               Conversations.create_conversation(valid_attrs)

      assert conversation.type == "private"
    end

    test "create_conversation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Conversations.create_conversation(@invalid_attrs)
    end

    test "update_conversation/2 with valid data updates the conversation" do
      conversation = conversation_fixture()
      update_attrs = %{type: "group"}

      assert {:ok, %Conversation{} = conversation} =
               Conversations.update_conversation(conversation, update_attrs)

      assert conversation.type == "group"
    end

    test "update_conversation/2 with invalid data returns error changeset" do
      conversation = conversation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Conversations.update_conversation(conversation, @invalid_attrs)

      assert conversation == Conversations.get_conversation!(conversation.id)
    end

    test "delete_conversation/1 deletes the conversation" do
      conversation = conversation_fixture()
      assert {:ok, %Conversation{}} = Conversations.delete_conversation(conversation)
      assert_raise Ecto.NoResultsError, fn -> Conversations.get_conversation!(conversation.id) end
    end

    test "change_conversation/1 returns a conversation changeset" do
      conversation = conversation_fixture()
      assert %Ecto.Changeset{} = Conversations.change_conversation(conversation)
    end
  end
end
