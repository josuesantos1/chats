defmodule Backend.Contacts.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "contacts" do
    belongs_to :user, Backend.Accounts.User
    belongs_to :contact, Backend.Accounts.User, foreign_key: :contact_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:user_id, :contact_id])
    |> validate_required([:user_id, :contact_id])
  end
end
