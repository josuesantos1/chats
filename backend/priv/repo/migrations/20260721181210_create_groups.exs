defmodule Backend.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :id, :uuid
      add :name, :string
      add :creator, references(:users, on_delete: :nothing)
      add :conversation, references(:conversations, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:groups, [:creator])
    create index(:groups, [:conversation])
  end
end
