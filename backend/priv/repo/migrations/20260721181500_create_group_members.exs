defmodule Backend.Repo.Migrations.CreateGroupMembers do
  use Ecto.Migration

  def change do
    create table(:group_members, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :group_id, references(:groups, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:group_members, [:group_id])
    create index(:group_members, [:user_id])
    create unique_index(:group_members, [:group_id, :user_id])
  end
end
