defmodule AuthServer.Handler do
  use Freddie.Router

  require Logger

  alias AuthServer.Handler

  defhandler AuthServer.Scheme.CS_Signin do
    {meta, msg, context}
    |> Handler.Signin.handle()
  end

  defhandler AuthServer.Scheme.CS_Signup do
    {meta, msg, context}
    |> Handler.Signup.handle()
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
