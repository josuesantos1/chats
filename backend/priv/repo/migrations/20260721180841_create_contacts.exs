defmodule Backend.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :nothing)
      add :contact_id, references(:users, type: :uuid, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:contacts, [:user_id])
    create index(:contacts, [:contact_id])
  end
end
