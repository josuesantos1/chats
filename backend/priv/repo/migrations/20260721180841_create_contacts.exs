defmodule Backend.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user, references(:users, type: :uuid, on_delete: :nothing)
      add :contact, references(:users, type: :uuid, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:contacts, [:user])
    create index(:contacts, [:contact])
  end
end
