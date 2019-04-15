defmodule AuthServer.Handler.Signin do
  @behaviour AuthServer.Handler.Base

  require Logger

  alias AuthServer.Repo
  alias AuthServer.Helper
  alias AuthServer.Model.User
  alias AuthServer.Scheme.SC_Signin

  alias Freddie.Redis.Pool, as: Redis

  @redis_session_counter "unique:session:counter"

  def handle(request) do
    data = elem(request, 1)
    context = elem(request, 2)

    response =
      data
      |> validate_user()
      |> make_response()

    Freddie.Session.send(context, response, use_encryption: true)

    context
  end

  defp make_response({:error, reason}) do
    SC_Signin.new(result: Helper.make_result(false, reason))
  end

  defp make_response({:ok, user}) do
    # Todo: Manage lobby load balancing
    # Todo: 방 추가되면 db에서 방 정보도 redis에 추가
    case AuthServer.Compass.choose_lobby() do
      nil ->
        # 서버 장애?
        Logger.error("Cannot found lobby servers")
        SC_Signin.new(result: Helper.make_result(false, :server_is_busy))

      {lobby_name, {lobby_host, _connected_session}} ->
        # session key를 우선 발급 받는다.
        case Redis.command(["INCR", @redis_session_counter]) do
          {:ok, session_key} ->
            access_token = Helper.make_rand_string()

            # Todo: 유령 세션, 세션 별 gc 전략 고려해서 추가 해야할듯.. 몇초안에 로비 통과 하지 않으면 떨군다던지
            Redis.transaction_pipeline([
              # 부여받은 session key로 user 정보 update
              [
                "HMSET",
                "session:#{session_key}",
                "user_id",
                user.user_id,
                "access_token",
                access_token
              ],

              # 로비 서버에 연결된 세션 추가
              ["LPUSH", "lobby:#{lobby_name}:session_list", session_key]
            ])

            Logger.info(
              "[Debug] => lobby_host: #{inspect(lobby_host)}, session_key: #{inspect(session_key)}"
            )

            SC_Signin.new(
              result: Helper.make_result(true, :none),
              server_ip: "127.0.0.1",
              server_port: "5055",
              session_key: to_string(session_key),
              access_token: access_token
            )

          # 세션키 발급 실패
          _ ->
            Logger.error("failed to assign session key")
            SC_Signin.new(result: Helper.make_result(false, :server_is_busy))
        end
    end
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
