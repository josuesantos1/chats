defmodule Backend.ContactsTest do
  use Backend.DataCase

  alias Backend.Contacts

  describe "contacts" do
    alias Backend.Contacts.Contact

    import Backend.ContactsFixtures
    import Backend.AccountsFixtures

    @invalid_attrs %{user_id: nil, contact_id: nil}

    test "list_contacts/0 returns all contacts" do
      contact = contact_fixture()
      assert Enum.any?(Contacts.list_contacts(), &(&1.id == contact.id))
    end

    test "list_contacts_for_user/1 returns only contacts belonging to user" do
      contact = contact_fixture()
      other_contact = contact_fixture()

      result = Contacts.list_contacts_for_user(contact.user_id)
      assert Enum.any?(result, &(&1.id == contact.id))
      refute Enum.any?(result, &(&1.id == other_contact.id))
    end

    test "list_contacts_for_user/1 returns empty list for user with no contacts" do
      user = user_fixture()
      assert Contacts.list_contacts_for_user(user.id) == []
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Contacts.get_contact!(contact.id) == contact
    end

    test "get_contact_for_user/2 returns the contact when owned by user" do
      contact = contact_fixture()
      result = Contacts.get_contact_for_user(contact.id, contact.user_id)
      assert result.id == contact.id
    end

    test "get_contact_for_user/2 returns nil when contact is not owned by user" do
      contact = contact_fixture()
      other_user = user_fixture()
      assert Contacts.get_contact_for_user(contact.id, other_user.id) == nil
    end

    test "create_contact/1 with valid data creates a contact" do
      user = user_fixture()
      contact_user = user_fixture()
      valid_attrs = %{user_id: user.id, contact_id: contact_user.id}

      assert {:ok, %Contact{} = contact} = Contacts.create_contact(valid_attrs)
      assert contact.user_id == user.id
      assert contact.contact_id == contact_user.id
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact(@invalid_attrs)
    end

    test "update_contact/2 with valid data updates the contact" do
      contact = contact_fixture()
      new_user = user_fixture()
      update_attrs = %{user_id: new_user.id}

      assert {:ok, %Contact{} = contact} = Contacts.update_contact(contact, update_attrs)
      assert contact.user_id == new_user.id
    end

    test "update_contact/2 with invalid data returns error changeset" do
      contact = contact_fixture()
      assert {:error, %Ecto.Changeset{}} = Contacts.update_contact(contact, @invalid_attrs)
      assert contact == Contacts.get_contact!(contact.id)
    end

    test "delete_contact/1 deletes the contact" do
      contact = contact_fixture()
      assert {:ok, %Contact{}} = Contacts.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(contact.id) end
    end

    test "change_contact/1 returns a contact changeset" do
      contact = contact_fixture()
      assert %Ecto.Changeset{} = Contacts.change_contact(contact)
    end
  end
end
