defmodule Backend.Repo.Migrations.AddUniqueIndexToContacts do
  use Ecto.Migration

  def change do
    create unique_index(:contacts, [:user_id, :contact_id])
  end
end
