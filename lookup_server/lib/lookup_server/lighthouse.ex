defmodule LookupServer.Lighthouse do
  use GenServer

  require Logger

  alias ExHashRing.HashRing, as: Ring

  defstruct chat_node_ring: nil,
            subscribed_info: %{}

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  defp publish_hash_ring(
         %__MODULE__{
           chat_node_ring: chat_node_ring,
           subscribed_info: subscribed_info
         } = mod
       ) do
    new_subscribed_info =
      subscribed_info
      |> Stream.map(&do_publish_hash_ring(&1, chat_node_ring))
      |> Stream.filter(&(&1 != nil))
      |> Enum.into(%{})

    %__MODULE__{mod | subscribed_info: new_subscribed_info}
  end

  defp do_publish_hash_ring({_node, pid} = node_info, chat_node_ring) do
    try do
      send(pid, {:publish_hash_ring, chat_node_ring})
      node_info
    rescue
      _ -> nil
    end
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

    {:lookup_group, groups} = LookupServer.Agent.lookup_group("chat")

    chat_node_ring =
      groups
      |> Enum.reduce(Ring.new(), fn node_info, acc ->
        {:ok, ring} = Ring.add_node(acc, node_info.name)
        ring
      end)

    # Todo: Subscribed 됐던 노드들 다시 캐시해야된다. 클라이언트에서 붙여야할듯

    {:ok, %__MODULE__{chat_node_ring: chat_node_ring}}
  end

  @doc """
  Use like send({:"Elixir.LookupServer.Lighthouse", :lookup_server_001@localhost}, {:register, group, node()})
  """
  @impl true
  def handle_info({:register, group, node}, %__MODULE__{chat_node_ring: chat_node_ring} = state) do
    Logger.info("Reigter node - #{inspect(node)}!")
    LookupServer.Agent.register(group, node)
    Node.monitor(node, true)

    # chat server의 경우는 consistent hash ring을 만들어야 하므로 따로 처리 후 publish
    new_state =
      if group == "chat" do
        [node_name, _host] =
          node
          |> to_string()
          |> String.split("@")

        {:ok, chat_node_ring} =
          Ring.add_node(chat_node_ring, node_name)
          |> IO.inspect(label: "Debug => ring: ")

        # subscribe 중인 노드들에 hash ring의 변화를 통지한다.
        %__MODULE__{state | chat_node_ring: chat_node_ring}
        |> publish_hash_ring()
      else
        state
      end

    {:noreply, new_state}
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

  @doc """
  Use like send({:"Elixir.LookupServer.Lighthouse", :lookup_server_001@localhost}, {:subscribe_hash_ring, self(), node()})
  """
  @impl true
  def handle_info({:subscribe_hash_ring, request_pid, node}, state) do
    Logger.info("Add Subscribe node - #{inspect(node)} , pid - #{inspect(request_pid)}")

    new_state = %__MODULE__{
      state
      | subscribed_info: Map.put(state.subscribed_info, node, request_pid)
    }

    do_publish_hash_ring({node, request_pid}, new_state.chat_node_ring)

    {:noreply, new_state}
  end

  @impl true
  def handle_info(
        {:nodedown, down_node},
        %__MODULE__{chat_node_ring: chat_node_ring, subscribed_info: subscribed_info} = state
      ) do
    Logger.info("Delete node - #{inspect(down_node)}!")

    # down된 node가 subscribe 중인 노드라면 리스트에서 지워준다.
    new_state = %__MODULE__{state | subscribed_info: Map.delete(subscribed_info, down_node)}

    new_state =
      case LookupServer.Agent.lookup(down_node) do
        {:lookup, nil} ->
          new_state

        {:lookup, node_info} ->
          # down된 node가 chat node라면 hash ring을 갱신한다.
          if node_info.group == "chat" do
            {:ok, chat_node_ring} =
              Ring.remove_node(chat_node_ring, node_info.name)
              |> IO.inspect(label: "Debug => ring: ")

            # subscribe 중인 노드들에 hash ring의 변화를 통지한다.
            %__MODULE__{new_state | chat_node_ring: chat_node_ring}
            |> publish_hash_ring()
          else
            new_state
          end
      end

    LookupServer.Agent.delete(down_node)

    {:noreply, new_state}
  end

  @impl true
  def handle_info(unknown_msg, state) do
    Logger.info("[Lighthouse] Received unkown_msg: #{inspect(unknown_msg)}")
    {:noreply, state}
  end
end
