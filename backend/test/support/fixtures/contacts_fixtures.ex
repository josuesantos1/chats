defmodule Backend.ContactsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Contacts` context.
  """

  import Backend.AccountsFixtures

  @doc """
  Generate a contact between two new users.
  """
  def contact_fixture(attrs \\ %{}) do
    user = user_fixture()
    contact_user = user_fixture()

    {:ok, contact} =
      attrs
      |> Enum.into(%{
        user_id: user.id,
        contact_id: contact_user.id
      })
      |> Backend.Contacts.create_contact()

    contact
  end
end
