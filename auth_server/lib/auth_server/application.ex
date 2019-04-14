defmodule AuthServer.Application do
  use Application

  require Logger

  def start(_type, _args) do
    Supervisor.start_link(
      [
        AuthServer.Repo,
        {Freddie, [activate_eprof: true, activate_fprof: true]},
        AuthServer.Compass
      ],
      strategy: :one_for_one
    )
  end
end
