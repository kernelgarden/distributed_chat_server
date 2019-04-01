defmodule LobbyServer.Scheme do
  use Protobuf, from: Path.wildcard(Path.expand("./scheme/**/*.proto", __DIR__))
end
