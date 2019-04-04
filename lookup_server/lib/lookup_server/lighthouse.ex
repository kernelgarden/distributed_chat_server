defmodule LookupServer.Lighthouse do
  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    # Lighthouse 프로세스가 다운되면 Node간의 연결이 끊기게 된다.
    # 따라서 모든 Node들에 연결을 다시 수립한다.
    LookupServer.Agent.get_node_keys_stream()
    |> Stream.map(&(LookupServer.Agent.trans_key_to_node(&1)))
    |> Stream.filter(fn key -> key != nil end)
    |> Stream.each(fn node -> Node.monitor(node, true) end)
    |> Stream.run()

    {:ok, nil}
  end

  @doc """
  Use like send({:"Elixir.LookupServer.Lighthouse", :lookup_server_001@localhost}, {:register, group, node()})
  """
  @impl true
  def handle_info({:register, group, node}, state) do
    Logger.info(fn -> "Reigter node - #{inspect(node)}!" end)
    LookupServer.Agent.register(group, node)
    Node.monitor(node, true)
    {:noreply, state}
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
  def handle_info({:nodedown, down_node}, state) do
    Logger.info(fn -> "Delete node - #{inspect(down_node)}!" end)
    LookupServer.Agent.delete(down_node)
    {:noreply, state}
  end
end
