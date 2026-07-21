defmodule Backend.Contacts.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contacts" do
    field :id, Ecto.UUID
    field :user, :id
    field :contact, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:id])
    |> validate_required([:id])
  end
end
