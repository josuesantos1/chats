defmodule Backend.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
@foreign_key_type :binary_id

  schema "messages" do
    field :content, :string
    belongs_to :author, Backend.Accounts.User, foreign_key: :author_id
    belongs_to :conversation, Backend.Conversations.Conversation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :author_id, :conversation_id])
    |> validate_required([:content, :author_id, :conversation_id])
  end
end
