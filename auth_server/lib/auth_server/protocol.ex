defmodule AuthServer.Protocol do
  use EnumType

  # define packet type and packet number (please type full name)
  defenum Types do
    # sign up
    value(AuthServer.Scheme.CS_Signup, 7)
    value(AuthServer.Scheme.SC_Signup, 8)

    # sign in
    value(AuthServer.Scheme.CS_Signin, 9)
    value(AuthServer.Scheme.SC_Signin, 10)
  end
end
