defmodule BackendWeb.ContactControllerTest do
  use BackendWeb.ConnCase

  import Backend.AccountsFixtures
  alias Backend.Contacts

  @invalid_attrs %{user_id: nil, contact_id: nil}

  setup %{conn: conn, current_user: current_user} do
    contact_user = user_fixture()

    create_attrs = %{user_id: current_user.id, contact_id: contact_user.id}

    {:ok,
     conn: put_req_header(conn, "accept", "application/json"),
     create_attrs: create_attrs,
     contact_user: contact_user}
  end

  describe "index" do
    test "lists contacts for the current user", %{conn: conn} do
      conn = get(conn, ~p"/api/contacts")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create contact" do
    test "renders contact when data is valid", %{conn: conn, create_attrs: create_attrs} do
      conn = post(conn, ~p"/api/contacts", contact: create_attrs)
      assert %{"id" => _id} = json_response(conn, 201)["data"]
    end

    test "returns existing contact if duplicate", %{conn: conn, create_attrs: create_attrs} do
      post(conn, ~p"/api/contacts", contact: create_attrs)
      conn = post(conn, ~p"/api/contacts", contact: create_attrs)
      assert %{"id" => _id} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, current_user: current_user} do
      conn =
        post(conn, ~p"/api/contacts", contact: %{user_id: current_user.id, contact_id: nil})

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 403 when user_id does not match current user", %{
      conn: conn,
      contact_user: contact_user
    } do
      other_user = user_fixture()
      attrs = %{user_id: other_user.id, contact_id: contact_user.id}
      conn = post(conn, ~p"/api/contacts", contact: attrs)
      assert json_response(conn, 403)["error"] != nil
    end

    test "returns 400 when trying to add yourself as contact", %{
      conn: conn,
      current_user: current_user
    } do
      attrs = %{user_id: current_user.id, contact_id: current_user.id}
      conn = post(conn, ~p"/api/contacts", contact: attrs)
      assert json_response(conn, 400)["error"] != nil
    end
  end

  describe "update contact" do
    setup [:create_contact]

    test "renders contact when data is valid", %{
      conn: conn,
      contact: contact,
      contact_user: contact_user
    } do
      conn = put(conn, ~p"/api/contacts/#{contact}", contact: %{contact_id: contact_user.id})
      assert %{"id" => id} = json_response(conn, 200)["data"]
      assert id == contact.id
    end

    test "renders errors when data is invalid", %{conn: conn, contact: contact} do
      conn = put(conn, ~p"/api/contacts/#{contact}", contact: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 404 when contact does not belong to current user", %{conn: conn} do
      other_contact = Backend.ContactsFixtures.contact_fixture()
      conn = put(conn, ~p"/api/contacts/#{other_contact}", contact: %{})
      assert json_response(conn, 404)["error"] != nil
    end
  end

  describe "delete contact" do
    setup [:create_contact]

    test "deletes chosen contact", %{conn: conn, contact: contact} do
      conn = delete(conn, ~p"/api/contacts/#{contact}")
      assert response(conn, 204)
    end

    test "returns 404 when contact does not belong to current user", %{conn: conn} do
      other_contact = Backend.ContactsFixtures.contact_fixture()
      conn = delete(conn, ~p"/api/contacts/#{other_contact}")
      assert json_response(conn, 404)["error"] != nil
    end
  end

  defp create_contact(%{current_user: current_user, contact_user: contact_user}) do
    {:ok, contact} =
      Contacts.create_contact(%{
        user_id: current_user.id,
        contact_id: contact_user.id
      })

    %{contact: contact}
  end
end
