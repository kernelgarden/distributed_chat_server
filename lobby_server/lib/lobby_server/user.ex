defmodule LobbyServer.User do
  use GenServer

  require Logger

  alias __MODULE__
  alias __MODULE__.Helper

  defstruct id: 0,
            session_key: "",
            room_list: []

  @spec start_link(%User{}) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(user_info) do
    GenServer.start_link(__MODULE__, user_info, name: Helper.via_tuple(user_info.id))
  end

  @spec kill(integer()) :: :ok
  def kill(user_id) do
    GenServer.cast(Helper.via_tuple(user_id), :kill)
  end

  @spec new(integer(), binary(), [integer()]) :: LobbyServer.User.t()
  def new(id, session_key, room_list \\ []) do
    %User{id: id, session_key: session_key, room_list: room_list}
  end

  @impl true
  def init(user_info) do
    {:ok, user_info}
  end

  @impl true
  def handle_cast(:kill, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_info(_unknown_msg, state) do
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, _state) do
    Redis.command(["HDEL", "session:#{data.session_key}"])
    # TODO: session list도 날려야한다.
    :ok
  end
end
