defmodule Backend.Repo.Migrations.CreateConversationMembers do
  use Ecto.Migration

  def change do
    create table(:conversation_members, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :conversation_id, references(:conversations, type: :uuid, on_delete: :delete_all),
        null: false

      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:conversation_members, [:conversation_id])
    create index(:conversation_members, [:user_id])
    create unique_index(:conversation_members, [:conversation_id, :user_id])
  end
end
