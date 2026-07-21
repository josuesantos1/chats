defmodule Backend.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :id, Ecto.UUID
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
