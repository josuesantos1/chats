defmodule Backend.GroupsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Groups` context.
  """

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(%{
        id: "7488a646-e31f-11e4-aace-600308960662",
        name: "some name"
      })
      |> Backend.Groups.create_group()

    group
  end
end
