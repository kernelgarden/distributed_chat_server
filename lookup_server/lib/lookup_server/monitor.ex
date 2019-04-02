defmodule LookupServer.Monitor do
  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    {:ok, nil}
  end

  @doc """
  Use like send({:"Elixir.LookupServer.Monitor", :lookup_server_001@localhost}, {:register, node()})
  """
  @impl true
  def handle_info({:register, node}, state) do
    Logger.info(fn -> "Reigter node - #{inspect node}!" end)
    LookupServer.Agent.register(node)
    {:noreply, state}
  end

  @doc """
  Use like send({:"Elixir.LookupServer.Monitor", :lookup_server_001@localhost}, {:lookup, name, self()})
  """
  @impl true
  def handle_info({:lookup, name, request_pid}, state) do
    response = LookupServer.Agent.lookup(name)
    send(request_pid, response)
    {:noreply, state}
  end

  @impl true
  def handle_info({:nodedown, down_node}, state) do
    Logger.info(fn -> "Delete node - #{inspect down_node}!" end)
    LookupServer.Agent.delete(down_node)
    {:noreply, state}
  end

end
