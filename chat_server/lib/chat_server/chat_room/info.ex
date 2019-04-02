defmodule ChatServer.ChatRoom.Info do

  alias __MODULE__

  defstruct room_id: 0,
            room_name: "",
            owner_id: 0,
            member_list: []


  @spec new(integer(), binary(), integer(), [integer()]) :: ChatServer.ChatRoom.Info.t()
  def new(room_id, room_name, owner_id, member_list \\ []) do
    %Info{room_id: room_id, room_name: room_name, owner_id: owner_id, member_list: member_list}
  end

end
