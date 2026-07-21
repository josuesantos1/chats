defmodule Backend.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :creator, references(:users, type: :uuid, on_delete: :nothing)
      add :conversation, references(:conversations, type: :uuid, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:groups, [:creator])
    create index(:groups, [:conversation])
  end
end
