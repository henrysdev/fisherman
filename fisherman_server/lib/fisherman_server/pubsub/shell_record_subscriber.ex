defmodule FishermanServer.Pubsub.ShellRecordSubscriber do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def init(_) do
    Phoenix.PubSub.subscribe(FishermanServer.PubSub, "shell_records")
    {:ok, %{}}
  end

  def handle_call(:get, _, state) do
    {:reply, state, state}
  end

  def handle_info({:new, msg}, state) do
    IO.inspect({:SUBSCRIBER_RECV, msg})
    {:noreply, state}
  end
end
