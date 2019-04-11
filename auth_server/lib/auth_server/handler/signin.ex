defmodule AuthServer.Handler.Signin do
  @behaviour AuthServer.Handler.Base

  require Logger

  alias AuthServer.Repo
  alias AuthServer.Helper
  alias AuthServer.Model.User
  alias AuthServer.Scheme.SC_Signin

  def handle(request) do
    data = elem(request, 1)
    context = elem(request, 2)

    response =
      data
      |> validate_user()
      |> make_response()

    Freddie.Session.send(context, response)

    context
  end

  defp make_response({:error, reason}) do
    SC_Signin.new(result: Helper.make_result(false, reason))
  end

  defp make_response({:ok, user}) do
    # Todo: Manage lobby load balancing

    SC_Signin.new(
      result: Helper.make_result(true, :none),
      server_ip: "127.0.0.1",
      server_port: "5055"
    )
  end

  defp validate_user(data) do
    case Repo.get_by(User, user_id: data.user_id) do
      nil ->
        {:error, :inexists}

      stored_user ->
        case User.authenticate(stored_user, data.password) do
          true -> {:ok, stored_user}
          false -> {:error, :invalid}
        end
    end
  end
end
