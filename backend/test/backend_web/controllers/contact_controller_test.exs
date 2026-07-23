defmodule BackendWeb.ContactControllerTest do
  use BackendWeb.ConnCase

  import Backend.ContactsFixtures
  import Backend.AccountsFixtures
  alias Backend.Contacts.Contact

  @invalid_attrs %{user_id: nil, contact_id: nil}

  setup %{conn: conn} do
    user = user_fixture(%{email: "user@email.com", username: "user"})
    contact_user = user_fixture(%{email: "contact@email.com", username: "contact"})

    create_attrs = %{user_id: user.id, contact_id: contact_user.id}

    {:ok, conn: put_req_header(conn, "accept", "application/json"), create_attrs: create_attrs}
  end

  describe "index" do
    test "lists all contacts", %{conn: conn} do
      conn = get(conn, ~p"/api/contacts")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create contact" do
    test "renders contact when data is valid", %{conn: conn, create_attrs: create_attrs} do
      conn = post(conn, ~p"/api/contacts", contact: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/contacts/#{id}")
      assert %{"id" => ^id} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/contacts", contact: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update contact" do
    setup [:create_contact]

    test "renders contact when data is valid", %{
      conn: conn,
      contact: %Contact{id: id} = contact,
      create_attrs: create_attrs
    } do
      conn = put(conn, ~p"/api/contacts/#{contact}", contact: create_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, contact: contact} do
      conn = put(conn, ~p"/api/contacts/#{contact}", contact: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete contact" do
    setup [:create_contact]

    test "deletes chosen contact", %{conn: conn, contact: contact} do
      conn = delete(conn, ~p"/api/contacts/#{contact}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/contacts/#{contact}")
      end
    end
  end

  defp create_contact(_) do
    contact = contact_fixture()
    %{contact: contact}
  end
end
