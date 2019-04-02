defmodule ChatServer.ChatRoom do
  use GenServer

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
