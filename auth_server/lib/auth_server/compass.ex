defmodule AuthServer.Compass do
  use GenServer

  alias Freddie.Redis.Pool, as: Redis

  @refresh_lobby_delay 5000

  defstruct lobby_server_list: %{},
            lookup_server_list: []

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  defp attach_to_lookup_server(lookup_server_list) do
    Enum.each(lookup_server_list, fn lookup_server_node ->
      Node.connect(lookup_server_node)
      send({:"Elixir.LookupServer.Lighthouse", lookup_server_node}, {:register, "auth", node()})
    end)
  end

  defp request_lobby_server_list(nil) do
    :noop
  end

  defp request_lobby_server_list(lookup_server_node) do
    send({:"Elixir.LookupServer.Lighthouse", lookup_server_node}, {:lookup_group, "lobby", self()})
  end

  defp make_update_status_query(lobby_server_list) do
    lobby_server_list
    |> Enum.map(fn {name, _node} ->
      ["SCARD", "lobby:#{name}:sessionlist"]
    end)
  end

  @impl true
  @spec init(any()) :: {:ok, AuthServer.Compass.t()}
  def init(_args) do
    state = %__MODULE__{
              lookup_server_list: Application.get_env(:auth_server, :lookup_server_list, [])
            }
    attach_to_lookup_server(state.lookup_server_list)
    {:ok, state}
  end

  @impl true
  def handle_info({:update_lobby_server, lobby_server_list}, state) do
    new_lobby_server_list =
      lobby_server_list
      |> Enum.map(fn {name, _group, %{host: node_host}} -> {name, {node_host, Map.get(state.lobby_server_list, name, 0)}} end)
      |> Enum.into(%{})

    # 로비 서버당 연결된 세션 개수도 갱신하자
    GenServer.cast(self(), :update_lobby_status)
    query = make_update_status_query(state.lobby_server_list)
    {:ok, status_list} = Redis.pipeline(query)

    state.lobby_server_list
    |> Enum.with_index()
    |> Enum.reduce(state.lobby_server_list, fn {{name, {node, _connected_num}}, idx}, acc ->
      Map.put(acc, name, {node, Enum.at(status_list, idx, 0)})
    end)

    {:ok, Map.put(state, :lobby_server_list, new_lobby_server_list)}
  end

  @impl true
  def handle_info(:refresh_lobby_server, state) do
    # 부하 분산을 위해 랜덤한 룩업 서버에 요청한다.
    state.lookup_server_list
    |> Enum.random()
    |> request_lobby_server_list()

    Process.send_after(self(), :refresh_lobby_server, @refresh_lobby_delay)
    {:noreply, state}
  end

  @impl true
  def handle_info(_unknown_msg, state) do
    {:noreply, state}
  end
end
