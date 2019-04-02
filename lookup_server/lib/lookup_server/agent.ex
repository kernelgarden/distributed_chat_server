defmodule LookupServer.Agent do
  use Agent

  alias LookupServer.NodeInfo

  def start_link(_args) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @spec register(atom()) :: :ok
  def register(node) when is_atom(node) do
    register(to_string(node))
  end

  @spec register(binary()) :: :ok
  def register(node) when is_binary(node) do
    [name, host] =
      node
      |> String.split("@")

    do_register(name, host)
  end

  @spec delete(atom()) :: :ok
  def delete(node) when is_atom(node) do
    delete(to_string(node))
  end

  @spec delete(binary()) :: :ok
  def delete(node) when is_binary(node) do
    [name, _host] =
      node
      |> String.split("@")

    do_delete(name)
  end

  @spec lookup(any()) :: any()
  def lookup(node_name) do
    Agent.get(__MODULE__, fn nodes ->
      Map.get(nodes, node_name, nil)
    end)
  end

  defp do_register(node_name, node_host) do
    Agent.update(__MODULE__, fn nodes ->
      node_info = NodeInfo.new(node_name, node_host)
      Map.put_new(nodes, node_name, node_info)
    end)
  end

  defp do_delete(node_name) do
    Agent.update(__MODULE__, fn nodes ->
      Map.delete(nodes, node_name)
    end)
  end
end
