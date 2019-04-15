defmodule LobbyServer.ChatServerHashRing do
  alias ExHashRing.HashRing

  require Logger

  @spec fetch(HashRing.t()) :: :ok
  def fetch(new_hash_ring) do
    Logger.info("Hash ring is changed: \n#{inspect(new_hash_ring)}")
    FastGlobal.put(:chat_server_hash_ring, new_hash_ring)
  end

  @spec get() :: HashRing.t()
  def get() do
    FastGlobal.get(:chat_server_hash_ring)
  end

  def lookup(chat_room_name) do
    case get() do
      nil ->
        nil

      hash_ring ->
        hash_ring
        |> HashRing.find_node(chat_room_name)
    end
  end
end
