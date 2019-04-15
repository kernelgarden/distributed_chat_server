defmodule LobbyServer.Handler do
  use Freddie.Router

  require Logger

  alias LobbyServer.Handler

  defhandler LobbyServer.Scheme.CS_Join do
    {meta, msg, context}
    |> Handler.Join.handle()
  end

  # define connnection event handler
  connect do
    Logger.info("Client #{inspect(context)} is connected!")
  end

  # define disconnection event handler
  disconnect do
    Logger.info("Client #{inspect(context)} is disconnected!")
  end
end
