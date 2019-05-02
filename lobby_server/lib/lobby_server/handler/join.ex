defmodule LobbyServer.Handler.Join do
  @behaviour LobbyServer.Handler.Base

  require Logger

  alias Freddie.Redis.Pool, as: Redis

  alias LobbyServer.User
  alias LobbyServer.Helper
  alias LobbyServer.Scheme.SC_Join

  def handle(request) do
    data = elem(request, 1)
    context = elem(request, 2)

    response =
      case Redis.command([
             "HMGET",
             "session:#{data.session_key}",
             "user_id",
             "access_token",
             "room_list"
           ]) do
        [] ->
          SC_Join.new(result: Helper.make_result(false, :inexists))

        [user_id, access_token, room_list] ->
          if user_id == data.user_id && access_token == data.access_token do
            # user가 속한 room_list 구해서 유저한테 뿌려줘야한다. room에는 user들의 정보도 들어간다.
            # Todo: room_list 추가되면 여기도 추가
            Freddie.Context.put(context, :user, User.new(user_id, data.session_key, []))

            SC_Join.new(result: Helper.make_result(true, :none))
          else
            SC_Join.new(result: Helper.make_result(false, :invalid))
          end
      end

    Freddie.Session.send(context, response)
    context
  end
end
