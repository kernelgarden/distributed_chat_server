defmodule LobbyServer.Handler do
  use Freddie.Router

  require Logger

  alias LobbyServer.User
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

    # redis에서 세션 해당 세션 키를 지워버려야한다.
    case Map.get(context, :user, nil) do
      nil ->
        :noop

      user ->
        # user process를 종료
        User.kill(user.id)
    end
  end
end
