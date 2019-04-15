defmodule LobbyServer.User.Helper do
  @spec via_tuple(integer()) :: {:via, Registry, {LobbyServer.User.Registry, integer()}}
  def via_tuple(user_id) do
    LobbyServer.User.Registry.via_tuple(user_id)
  end
end
