defmodule AuthServer.Compass do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  defp attach_to_lookup_server do
    Application.get_env(:auth_server, :lookup_server_list, [])
    |> Enum.each(fn lookup_server_node ->
      Node.connect(lookup_server_node)
      send({:"Elixir.LookupServer.Lighthouse", lookup_server_node}, {:register, "auth", node()})
    end)
  end

  @impl true
  def init(_args) do
    attach_to_lookup_server()
    {:ok, nil}
  end

  @impl true
  def handle_info(_unknown_msg, state) do
    {:noreply, state}
  end
end
