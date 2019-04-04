defmodule ChatServer.ChatRoom.Supervisor do
  use DynamicSupervisor

  require Logger

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(args \\ []) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def start_child(room_info) do
    DynamicSupervisor.start_child(__MODULE__, {ChatServer.ChatRoom, room_info})
  end

  @impl true
  @spec init(any()) ::
          {:ok,
           %{
             extra_arguments: [any()],
             intensity: non_neg_integer(),
             max_children: :infinity | non_neg_integer(),
             period: pos_integer(),
             strategy: :one_for_one
           }}
  def init(_args) do
    Process.flag(:trap_exit, true)

    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec handle_info({:EXIT, any(), any()}, any()) :: {:noreply, any()}
  def handle_info({:EXIT, from, reason}, state) do
    Logger.error(fn -> "player #{inspect(from)} is down. reason: #{inspect(reason)}" end)
    {:noreply, state}
  end

end
