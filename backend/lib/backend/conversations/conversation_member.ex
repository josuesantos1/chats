defmodule Backend.Conversations.ConversationMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "conversation_members" do
    belongs_to :conversation, Backend.Conversations.Conversation
    belongs_to :user, Backend.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:conversation_id, :user_id])
    |> validate_required([:conversation_id, :user_id])
    |> unique_constraint([:conversation_id, :user_id])
  end
end
