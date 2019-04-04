defmodule LookupServer.NodeInfo do
  alias __MODULE__

  defstruct name: "",
            host: "",
            group: ""

  @spec new(binary(), binary(), binary()) :: LookupServer.NodeInfo.t()
  def new(node_name, node_host, group) do
    %NodeInfo{name: node_name, host: node_host, group: group}
  end

  @spec to_node_identifier(NodeInfo.t()) :: atom()
  def to_node_identifier(node_info) do
    :"#{node_info.name}@#{node_info.host}"
  end
end
