defmodule Backend.GroupsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Groups` context.
  """

  import Backend.AccountsFixtures
  import Backend.ConversationsFixtures

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    user = user_fixture()
    conversation = conversation_fixture(%{type: "group"})

    {:ok, group} =
      attrs
      |> Enum.into(%{
        name: "some name",
        creator_id: user.id,
        conversation_id: conversation.id
      })
      |> Backend.Groups.create_group()

    group
  end
end
