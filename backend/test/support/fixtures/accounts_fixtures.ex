defmodule Backend.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        id: "7488a646-e31f-11e4-aace-600308960662",
        name: "some name",
        username: "some username"
      })
      |> Backend.Accounts.create_user()

    user
  end
end
