defmodule Backend.Conversations.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "conversations" do
    field :type, :string

    has_many :conversation_members, Backend.Conversations.ConversationMember

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:type])
    |> validate_required([:type])
    |> validate_inclusion(:type, ["private", "group"])
  end
end
