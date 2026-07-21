defmodule Backend.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :id, :uuid
      add :user, references(:users, on_delete: :nothing)
      add :contact, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:contacts, [:user])
    create index(:contacts, [:contact])
  end
end
