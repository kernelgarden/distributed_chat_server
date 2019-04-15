defmodule LobbyServer.Handler.Base do
  @type request :: {Freddie.Scheme.Common.Meta, Freddie.Scheme.Common.Message, Freddie.Context}

  @callback handle(request :: request()) :: Freddie.Context
end
