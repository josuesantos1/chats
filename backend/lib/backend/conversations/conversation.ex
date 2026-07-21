defmodule Backend.Conversations.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversations" do
    field :id, Ecto.UUID
    field :type, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:id, :type])
    |> validate_required([:id, :type])
  end
end
