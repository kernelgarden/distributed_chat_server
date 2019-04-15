defmodule LobbyServer.Compass do
  use GenServer

  alias LobbyServer.ChatServerHashRing

  defstruct lookup_server_list: %{}

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  defp attach_to_lookup_server(lookup_server_list) do
    # 로비 서버는 랜덤한 노드에 붙인다.
    lookup_server = Enum.random(lookup_server_list)
    Node.connect(lookup_server)
    send({:"Elixir.LookupServer.Lighthouse", lookup_server}, {:register, "lobby", node()})

    send(
      {:"Elixir.LookupServer.Lighthouse", lookup_server},
      {:subscribe_hash_ring, self(), node()}
    )
  end

  @impl true
  @spec init(any()) :: {:ok, AuthServer.Compass.t()}
  def init(_args) do
    state = %__MODULE__{
      lookup_server_list: Application.get_env(:lobby_server, :lookup_server_list, [])
    }

    attach_to_lookup_server(state.lookup_server_list)
    {:ok, state}
  end

  @impl true
  def handle_info({:publish_hash_ring, chat_node_ring}, state) do
    ChatServerHashRing.fetch(chat_node_ring)
    {:noreply, state}
  end

  @impl true
  def handle_info(_unknown_msg, state) do
    {:noreply, state}
  end
end
