defmodule ChatServer.Application do
  use Application

  require Logger

  def start(_type, _args) do
    Supervisor.start_link(
      [
        ChatServer.Repo,
        ChatServer.ChatRoom.Supervisor,
        ChatServer.ChatRoom.Registry,
      ],
      strategy: :one_for_one
    )
  end
end
