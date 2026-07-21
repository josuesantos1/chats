defmodule Backend.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :id, Ecto.UUID
    field :name, :string
    field :creator, :id
    field :conversation, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:id, :name])
    |> validate_required([:id, :name])
  end
end
