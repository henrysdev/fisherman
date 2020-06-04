defmodule FishermanServer.Pubsub.NotificationPublisher do
  use GenServer

  alias FishermanServer.Utils

  require Logger

  @channel_name "notify_feed_refresh"

  @doc """
  Initialize the GenServer
  """
  @spec start_link([String.t()], [any]) :: {:ok, pid}
  def start_link(channel, otp_opts \\ []), do: GenServer.start_link(__MODULE__, channel, otp_opts)

  @doc """
  When the GenServer starts subscribe to the given channel
  """
  @spec init([String.t()]) :: {:ok, []}
  def init(channel) do
    Logger.debug("Starting #{__MODULE__} with channel subscription: #{channel}")
    pg_config = FishermanServer.Repo.config()
    {:ok, pid} = Postgrex.Notifications.start_link(pg_config)
    {:ok, ref} = Postgrex.Notifications.listen(pid, channel)
    {:ok, {pid, channel, ref}}
  end

  @doc """
  Listen for changes to shell records inserts
  """
  def handle_info({:notification, _pid, _ref, "shell_record_inserts", payload}, _state) do
    notif =
      payload
      |> Poison.decode!()
      |> Map.update!("command_timestamp", &Utils.pg_json_millis_to_dt(&1))
      |> Map.update!("error_timestamp", &Utils.pg_json_millis_to_dt(&1))

    IO.inspect({:NOTIF, notif})

    Phoenix.PubSub.broadcast(FishermanServer.PubSub, @channel_name, {:notify, notif})

    {:noreply, :event_handled}
  end

  def handle_info(_, _state), do: {:noreply, :event_received}
end