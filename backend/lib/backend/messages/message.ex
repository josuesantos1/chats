defmodule Backend.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
@foreign_key_type :binary_id

  schema "messages" do
    field :content, :string
    field :author, :id
    field :conversation, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:id, :content])
    |> validate_required([:id, :content])
  end
end
