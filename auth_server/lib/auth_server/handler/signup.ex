defmodule AuthServer.Handler.Signup do
  @behaviour AuthServer.Handler.Base

  require Logger

  alias AuthServer.Repo
  alias AuthServer.Helper
  alias AuthServer.Model.User
  alias AuthServer.Scheme.SC_Signup

  def handle(request) do
    data = elem(request, 1)
    context = elem(request, 2)

    response =
      data
      |> make_user()
      |> make_response()

    Freddie.Session.send(context, response)

    context
  end

  defp validate_user(data) do
    case Repo.get_by(User, user_id: data.user_id) do
      nil ->
        {:ok, data}

      _inexists_user ->
        {:error, :exists}
    end
  end

  defp make_user(data) do
    case validate_user(data) do
      {:ok, data} ->
        case insert_user(data) do
          {:ok, user} ->
            {:ok, user}

          {:error, _user} ->
            {:error, :unknown}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp make_response({:error, reason}) do
    Logger.error("[Singup Handler] Cannot make user!, reaseon: #{inspect(reason)}")

    SC_Signup.new(result: Helper.make_result(false, reason))
  end

  defp make_response({:ok, _user}) do
    SC_Signup.new(result: Helper.make_result(true, :none))
  end

  defp insert_user(data) do
    %User{}
    |> User.changeset(%{user_id: data.user_id, password: data.password, name: data.name})
    |> Repo.insert()
  end
end
