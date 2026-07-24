defmodule BackendWeb.ContactController do
  use BackendWeb, :controller

  alias Backend.Contacts
  alias Backend.Contacts.Contact

  action_fallback BackendWeb.FallbackController

  def index(conn, _params) do
    contacts = Contacts.list_contacts_for_user(conn.assigns.current_user.id)
    render(conn, :index, contacts: contacts)
  end

  def create(conn, %{"contact" => contact_params}) do
    existing =
      Contacts.list_contacts_for_user(conn.assigns.current_user.id)
      |> Enum.find(fn c -> c.contact_id == contact_params["contact_id"] end)

    cond do
      contact_params["user_id"] != conn.assigns.current_user.id ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You can only create contacts for yourself."})

      contact_params["user_id"] == contact_params["contact_id"] ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "You cannot add yourself as a contact."})

      existing != nil ->
        render(conn, :show, contact: existing)

      true ->
        with {:ok, %Contact{} = contact} <- Contacts.create_contact(contact_params) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", ~p"/api/contacts/#{contact}")
          |> render(:show, contact: contact)
        end
    end
  end

  def show(conn, %{"id" => id}) do
    contact = Contacts.get_contact!(id)
    render(conn, :show, contact: contact)
  end

  def update(conn, %{"id" => id, "contact" => contact_params}) do
    with %Contact{} = contact <- Contacts.get_contact_for_user(id, conn.assigns.current_user.id),
         {:ok, %Contact{} = contact} <- Contacts.update_contact(contact, contact_params) do
      render(conn, :show, contact: contact)
    else
      nil -> conn |> put_status(:not_found) |> json(%{error: "Not found."})
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Contact{} = contact <- Contacts.get_contact_for_user(id, conn.assigns.current_user.id),
         {:ok, %Contact{}} <- Contacts.delete_contact(contact) do
      send_resp(conn, :no_content, "")
    else
      nil -> conn |> put_status(:not_found) |> json(%{error: "Not found."})
      {:error, changeset} -> {:error, changeset}
    end
  end
end
