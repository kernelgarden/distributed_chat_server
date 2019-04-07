defmodule AuthServer.Protocol do
  use EnumType

  # define packet type and packet number (please type full name)
  defenum Types do
    # sign up
    value(AuthServer.Scheme.CS_Signup, 1)
    value(AuthServer.Scheme.SC_Signup, 2)

    # sign in
    value(AuthServer.Scheme.CS_Signin, 3)
    value(AuthServer.Scheme.SC_Signin, 4)
  end
end
