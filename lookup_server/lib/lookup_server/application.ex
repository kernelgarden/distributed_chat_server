defmodule LookupServer.Application do
  use Application

  def start(_type, _args) do
    LookupServer.Agent.set_up()

    Supervisor.start_link(
      [
        LookupServer.Lighthouse
      ],
      strategy: :one_for_one
    )
  end
end
