defmodule Backend.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :creator_id, references(:users, type: :uuid, on_delete: :nothing)
      add :conversation_id, references(:conversations, type: :uuid, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:groups, [:creator_id])
    create index(:groups, [:conversation_id])
  end
end
