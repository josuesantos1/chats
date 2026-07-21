defmodule Backend.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations) do
      add :id, :uuid
      add :type, :string

      timestamps(type: :utc_datetime)
    end
  end
end
