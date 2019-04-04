defmodule LookupServer.Lighthouse do
  use GenServer

  require Logger

  alias ExHashRing.HashRing, as: Ring

  defstruct chat_node_ring: nil

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    # Todo: Lighthouse 프로세스가 다운된 시점에서 변경된 topology에 대한 대응 처리
    # Lighthouse 프로세스가 다운되면 Node간의 연결이 끊기게 된다.
    # 따라서 모든 Node들에 연결을 다시 수립한다.
    LookupServer.Agent.get_node_keys_stream()
    |> Stream.map(&LookupServer.Agent.trans_key_to_node(&1))
    |> Stream.filter(fn key -> key != nil end)
    |> Stream.each(fn node -> Node.monitor(node, true) end)
    |> Stream.run()

    chat_node_ring =
      LookupServer.Agent.lookup_group("chat")
      |> Enum.reduce(Ring.new(), fn node_info, acc ->
        {:ok, ring} = Ring.add_node(acc, node_info.name)
        ring
      end)

    {:ok, %__MODULE__{chat_node_ring: chat_node_ring}}
  end

  @doc """
  Use like send({:"Elixir.LookupServer.Lighthouse", :lookup_server_001@localhost}, {:register, group, node()})
  """
  @impl true
  def handle_info({:register, group, node}, %__MODULE__{chat_node_ring: chat_node_ring} = state) do
    Logger.info(fn -> "Reigter node - #{inspect(node)}!" end)
    LookupServer.Agent.register(group, node)
    Node.monitor(node, true)

    # chat server의 경우는 consistent hash ring을 만들어야 하므로 따로 처리 후 publish
    new_chat_node_ring =
      if group == "chat" do
        [node_name, _host] =
          node
          |> to_string()
          |> String.split("@")

        {:ok, chat_node_ring} =
          Ring.add_node(chat_node_ring, node_name)
          |> IO.inspect(label: "Debug => ring: ")

        # Todo: ring publish 처리 추가
        chat_node_ring
      else
        chat_node_ring
      end

    {:noreply, %__MODULE__{state | chat_node_ring: new_chat_node_ring}}
  end

  @doc """
  Use like send({:"Elixir.LookupServer.Lighthouse", :lookup_server_001@localhost}, {:lookup, name, self()})
  """
  @impl true
  def handle_info({:lookup, name, request_pid}, state) do
    response = LookupServer.Agent.lookup(name)
    send(request_pid, response)
    {:noreply, state}
  end

  @doc """
  Use like send({:"Elixir.LookupServer.Lighthouse", :lookup_server_001@localhost}, {:lookup_group, group_name, self()})
  """
  @impl true
  def handle_info({:lookup_group, group_name, request_pid}, state) do
    response = LookupServer.Agent.lookup_group(group_name)
    send(request_pid, response)
    {:noreply, state}
  end

  @impl true
  def handle_info({:nodedown, down_node}, %__MODULE__{chat_node_ring: chat_node_ring} = state) do
    Logger.info(fn -> "Delete node - #{inspect(down_node)}!" end)

    new_chat_node_ring =
      case LookupServer.Agent.lookup(down_node) do
        nil ->
          chat_node_ring

        node_info ->
          if node_info.group == "chat" do
            {:ok, chat_node_ring} =
              Ring.remove_node(chat_node_ring, node_info.name)
              |> IO.inspect(label: "Debug => ring: ")

            # Todo: publish to subscribed nodes
            chat_node_ring
          else
            chat_node_ring
          end
      end

    LookupServer.Agent.delete(down_node)

    {:noreply, %__MODULE__{state | chat_node_ring: new_chat_node_ring}}
  end
end
