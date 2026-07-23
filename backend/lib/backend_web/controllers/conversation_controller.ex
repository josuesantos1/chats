defmodule BackendWeb.ConversationController do
  use BackendWeb, :controller

  alias Backend.Conversations
  alias Backend.Conversations.Conversation

  action_fallback BackendWeb.FallbackController

  def index(conn, _params) do
    conversations = Conversations.list_conversations_for_user(conn.assigns.current_user.id)
    render(conn, :index, conversations: conversations)
  end

  def create(conn, %{"conversation" => conversation_params}) do
    with {:ok, %Conversation{} = conversation} <-
           Conversations.create_conversation(conversation_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/conversations/#{conversation}")
      |> render(:show, conversation: conversation)
    end
  end

  def show(conn, %{"id" => id}) do
    conversation = Conversations.get_conversation!(id)
    render(conn, :show, conversation: conversation)
  end

  def update(conn, %{"id" => id, "conversation" => conversation_params}) do
    conversation = Conversations.get_conversation!(id)

    with {:ok, %Conversation{} = conversation} <-
           Conversations.update_conversation(conversation, conversation_params) do
      render(conn, :show, conversation: conversation)
    end
  end

  def delete(conn, %{"id" => id}) do
    conversation = Conversations.get_conversation!(id)

    with {:ok, %Conversation{}} <- Conversations.delete_conversation(conversation) do
      send_resp(conn, :no_content, "")
    end
  end

  def members(conn, %{"conversation_id" => conversation_id}) do
    members = Conversations.list_conversation_members(conversation_id)
    render(conn, :members, members: members)
  end

  def add_member(conn, %{"conversation_id" => conversation_id, "member" => member_params}) do
    attrs = Map.put(member_params, "conversation_id", conversation_id)

    with {:ok, _member} <- Conversations.add_conversation_member(attrs) do
      members = Conversations.list_conversation_members(conversation_id)
      render(conn, :members, members: members)
    end
  end
end
