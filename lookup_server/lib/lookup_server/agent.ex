defmodule LookupServer.Agent do
  import Ex2ms

  alias LookupServer.NodeInfo

  @cache_table :node_cache

  def set_up() do
    # managed by Application
    :ets.new(@cache_table, [:set, :public, :named_table])
  end

  @spec register(binary(), atom()) :: :ok
  def register(group, node) when is_atom(node) do
    register(group, to_string(node))
  end

  @spec register(binary(), binary()) :: :ok
  def register(group, node) when is_binary(node) do
    [name, host] =
      node
      |> String.split("@")

    do_register(name, host, group)
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

  @spec lookup_group(binary()) :: [NodeInfo.t()]
  def lookup_group(target_group) do
    query =
      fun do
        {_node_name, group, node_info} when group == ^target_group ->
          node_info
      end

    :ets.select(@cache_table, query)
  end

  @spec lookup(binary()) :: [NodeInfo.t()]
  def lookup(target_node_name) do
    query =
      fun do
        {node_name, _group, node_info} when node_name == ^target_node_name ->
          node_info
      end

    :ets.select(@cache_table, query)
  end

  def get_node_keys_stream() do
    Stream.resource(
      fn -> :ets.first(@cache_table) end,
      fn
        :"$end_of_table" ->
          {:halt, nil}

        prev_key ->
          {[prev_key], :ets.next(@cache_table, prev_key)}
      end,
      fn _ -> :ok end
    )
  end

  def trans_key_to_node(key) do
    :ets.lookup(@cache_table, key)
    |> do_trans_key_to_node()
  end

  defp do_register(node_name, node_host, group) do
    node_info = NodeInfo.new(node_name, node_host, group)
    :ets.insert(@cache_table, {node_name, group, node_info})
  end

  defp do_delete(node_name) do
    :ets.delete(@cache_table, node_name)
  end

  defp do_trans_key_to_node(query) do
    case query do
      [] -> nil
      [{_name, _group, node_info} | _] -> NodeInfo.to_node_identifier(node_info)
    end
  end
end
