defmodule Backend.ContactsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Contacts` context.
  """

  @doc """
  Generate a contact.
  """
  def contact_fixture(attrs \\ %{}) do
    {:ok, contact} =
      attrs
      |> Enum.into(%{
        id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Backend.Contacts.create_contact()

    contact
  end
end
