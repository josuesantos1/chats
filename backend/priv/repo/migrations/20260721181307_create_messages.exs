defmodule Backend.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :content, :text
      add :author_id, references(:users, type: :uuid, on_delete: :nothing)
      add :conversation_id, references(:conversations, type: :uuid, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:author_id])
    create index(:messages, [:conversation_id])
  end
end
