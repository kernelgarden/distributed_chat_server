defmodule LobbyServer.User do
  use GenServer

  require Logger

  alias __MODULE__
  alias __MODULE__.Helper

  defstruct id: 0,
            room_list: []

  @spec start_link(%User{}) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(user_info) do
    GenServer.start_link(__MODULE__, user_info, name: Helper.via_tuple(user_info.id))
  end

  @spec kill(integer()) :: :ok
  def kill(user_id) do
    GenServer.cast(Helper.via_tuple(user_id), :kill)
  end

  @spec new(integer(), [integer()]) :: LobbyServer.User.t()
  def new(id, room_list \\ []) do
    %User{id: id, room_list: room_list}
  end

  @impl true
  def init(user_info) do
    {:ok, user_info}
  end

  def handle_cast(:kill, state) do
    {:stop, :normal, state}
  end

  def handle_info(_unknown_msg, state) do
    {:noreply, state}
  end
end
