defmodule BackendWeb.UserSocket do
  use Phoenix.Socket

  channel "conversation:*", BackendWeb.ConversationChannel

  @impl true
  def connect(%{"user_id" => user_id}, socket, _connect_info) do
    case Backend.Accounts.get_user(user_id) do
      nil -> :error
      user -> {:ok, assign(socket, :current_user, user)}
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(_socket), do: nil
end
