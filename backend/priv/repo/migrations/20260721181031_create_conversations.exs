defmodule Backend.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :type, :string

      timestamps(type: :utc_datetime)
    end
  end
end
