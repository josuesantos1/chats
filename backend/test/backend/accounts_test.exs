defmodule Backend.AccountsTest do
  use Backend.DataCase

  alias Backend.Accounts

  describe "users" do
    alias Backend.Accounts.User

    import Backend.AccountsFixtures

    @invalid_attrs %{name: nil, username: nil, email: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Enum.any?(Accounts.list_users(), &(&1.id == user.id))
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id).id == user.id
    end

    test "get_user/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user(user.id).id == user.id
    end

    test "get_user/1 returns nil for unknown id" do
      assert Accounts.get_user(Ecto.UUID.generate()) == nil
    end

    test "get_user_by_username/1 returns the user with given username" do
      user = user_fixture()
      assert Accounts.get_user_by_username(user.username).id == user.id
    end

    test "get_user_by_username/1 returns nil for unknown username" do
      assert Accounts.get_user_by_username("nonexistent") == nil
    end

    test "verify_credentials/2 returns ok with valid credentials" do
      user = user_fixture()
      assert {:ok, verified_user} = Accounts.verify_credentials(user.username, "password123")
      assert verified_user.id == user.id
    end

    test "verify_credentials/2 returns error with wrong password" do
      user = user_fixture()
      assert {:error, :invalid_credentials} = Accounts.verify_credentials(user.username, "wrong")
    end

    test "verify_credentials/2 returns error for unknown username" do
      assert {:error, :invalid_credentials} =
               Accounts.verify_credentials("nonexistent", "password123")
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        name: "some name",
        username: "some_username",
        email: "some@email.com",
        password: "password123"
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.name == "some name"
      assert user.username == "some_username"
      assert user.email == "some@email.com"
      assert user.password_hash != nil
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 with missing password returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{name: "x", username: "x", email: "x@x.com"})
    end

    test "create_user/1 with short password returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{name: "x", username: "x", email: "x@x.com", password: "12"})
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        name: "some updated name",
        username: "some_updated_username",
        email: "updated@email.com"
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.name == "some updated name"
      assert user.username == "some_updated_username"
      assert user.email == "updated@email.com"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert Accounts.get_user!(user.id).id == user.id
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
