defmodule LookupServer.Application do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [
        LookupServer.Agent,
        LookupServer.Monitor
      ],
      strategy: :one_for_one
    )
  end
end
