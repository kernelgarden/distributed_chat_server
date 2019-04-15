defmodule LobbyServer.Protocol do
  use EnumType

  # define packet type and packet number (please type full name)
  defenum Types do
    value(LobbyServer.Scheme.CS_Join, 12)
    value(LobbyServer.Scheme.SC_Join, 13)
  end
end
