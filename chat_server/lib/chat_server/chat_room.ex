defmodule ChatServer.ChatRoom do
  use GenServer

  require Logger

  alias __MODULE__
  alias ChatServer.ChatRoom.Registry, as: RoomRegistry
  alias ChatServer.ChatRoom.Info, as: RoomInfo

  defstruct room_info: %RoomInfo{},
            connected_session_id: [],
            room_name: ""

  def start_link(room_info) do
    room_id = Keyword.get(room_info, :room_id)

    GenServer.start_link(__MODULE__, room_info, name: via_tuple(room_id))
  end

  def create(info) do
    with {:ok, room_id} <- Keyword.fetch(info, :room_id),
         {:ok, room_name} <- Keyword.fetch(info, :room_name),
         {:ok, owner_id} <- Keyword.fetch(info, :owner_id)
    do
      RoomInfo.new(room_id, room_name, owner_id, member_list: [owner_id])

    else
      err ->
        Logger.error(fn -> "Failed to create new room! info: #{inspect info}" end)
        err
    end
  end

  def find(room_id) do

  end

  @spec via_tuple(integer()) :: {:via, Registry, {ChatServer.ChatRoom.Registry, integer()}}
  def via_tuple(room_id) do
    RoomRegistry.via_tuple(room_id)
  end

  @impl true
  @spec init(ChatServer.ChatRoom.t()) :: {:ok, ChatServer.ChatRoom.t()}
  def init(room_info) do
    {:ok, %ChatRoom{room_info: room_info}}
  end

  @impl true
  def handle_info(_unknown_msg, state) do
    {:noreply, state}
  end

end
