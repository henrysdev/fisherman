defmodule FishermanServer.NotificationPublisher do
  @moduledoc """
  Publisher of postgres notify messages sent on insert of shell records
  """
  use GenServer
  require FishermanServer.GlobalConstants
  alias FishermanServer.GlobalConstants, as: Const
  alias FishermanServer.Utils
  require Logger

  @doc """
  Initialize the GenServer
  """
  def start_link(channel, otp_opts \\ []), do: GenServer.start_link(__MODULE__, channel, otp_opts)

  @doc """
  When the GenServer starts subscribe to the given channel
  """
  def init(channel) do
    Logger.debug("Starting #{__MODULE__} with channel subscription: #{channel}")
    pg_config = FishermanServer.Repo.config()
    {:ok, pid} = Postgrex.Notifications.start_link(pg_config)
    {:ok, ref} = Postgrex.Notifications.listen(pid, channel)
    {:ok, {pid, channel, ref}}
  end

  @doc """
  Listen for changes to shell records inserts and broadcast to the
  applicable user channels
  """
  def handle_info({:notification, _pid, _ref, Const.pg_channel(), payload}, _state) do
    notif =
      payload
      |> Poison.decode!()
      |> Map.update!("command_timestamp", &Utils.pg_json_millis_to_dt(&1))
      |> Map.update!("error_timestamp", &Utils.pg_json_millis_to_dt(&1))

    chan = Map.get(notif, "user_id") |> channel_name()
    Phoenix.PubSub.broadcast(FishermanServer.PubSub, chan, {:notify, notif})

    {:noreply, :event_handled}
  end

  def handle_info(_, _state), do: {:noreply, :event_received}

  def channel_name(user_id) do
    "#{Const.channel_name()}:#{user_id}"
  end
end
