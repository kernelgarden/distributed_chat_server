defmodule LobbyServer.Repo do
  use Ecto.Repo,
    otp_app: :lobby_server,
    adapter: Ecto.Adapters.MySQL
end
