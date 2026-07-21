defmodule BackendWeb.GroupController do
  use BackendWeb, :controller

  alias Backend.Groups
  alias Backend.Groups.Group

  action_fallback BackendWeb.FallbackController

  def index(conn, _params) do
    groups = Groups.list_groups()
    render(conn, :index, groups: groups)
  end

  def create(conn, %{"group" => group_params}) do
    with {:ok, %Group{} = group} <- Groups.create_group(group_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/groups/#{group}")
      |> render(:show, group: group)
    end
  end

  def show(conn, %{"id" => id}) do
    group = Groups.get_group!(id)
    render(conn, :show, group: group)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Groups.get_group!(id)

    with {:ok, %Group{} = group} <- Groups.update_group(group, group_params) do
      render(conn, :show, group: group)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Groups.get_group!(id)

    with {:ok, %Group{}} <- Groups.delete_group(group) do
      send_resp(conn, :no_content, "")
    end
  end
end
