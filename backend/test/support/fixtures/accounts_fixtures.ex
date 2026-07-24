defmodule Backend.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Accounts` context.
  """

  @doc """
  Generate a unique user.
  """
  def user_fixture(attrs \\ %{}) do
    n = System.unique_integer([:positive])

    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "user#{n}@example.com",
        name: "User #{n}",
        username: "user#{n}",
        password: "password123"
      })
      |> Backend.Accounts.create_user()

    user
  end
end
