defmodule Backend.Groups.GroupMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "group_members" do
    belongs_to :group, Backend.Groups.Group
    belongs_to :user, Backend.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:group_id, :user_id])
    |> validate_required([:group_id, :user_id])
    |> unique_constraint([:group_id, :user_id])
  end
end
