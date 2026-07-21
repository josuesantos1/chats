defmodule Backend.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :id, :uuid
      add :content, :text
      add :author, references(:users, on_delete: :nothing)
      add :conversation, references(:conversations, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:author])
    create index(:messages, [:conversation])
  end
end
