defmodule Backend.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "groups" do
    field :name, :string
    belongs_to :creator, Backend.Accounts.User, foreign_key: :creator_id
    belongs_to :conversation, Backend.Conversations.Conversation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :creator_id, :conversation_id])
    |> validate_required([:name, :creator_id, :conversation_id])
  end
end
