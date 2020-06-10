defmodule FishermanServerWeb.ShellFeedLive do
  @moduledoc """
  Entry point for shell feed liveview. Mounts a liveview that
  registers as a subscriber to the user whos history is being
  recorded.

  The subscriber gets a change-data-capture notify event
  when a new shell record for a relevant user has been inserted,
  at which point the view is refreshed.
  """
  use Phoenix.LiveView
  alias FishermanServer.DB

  @min_rows 3
  @min_record_height 2.5
  @row_height 3.5
  @pid_col_width 20.0
  @time_incr 1_000

  def render(assigns) do
    ~L"""
    <%= live_component @socket,
        FishermanServerWeb.Live.ShellRecordsTableComponent,
        pids: active_shells(@state.records),
        records: @state.records,
        row_info: @state.row_info %>
    """

    # ~L"""
    # <%= live_component @socket,
    #     FishermanServerWeb.Live.RelativeShellsTableComponent,
    #     pids: active_shells(@state.records),
    #     records: @state.records,
    #     row_info: @state.row_info %>
    # """
  end

  def mount(_params, %{"user_id" => user_id, "from_ts" => curr_dt} = _session, socket) do
    # On mount, subscribe to appropriate feed
    Phoenix.PubSub.subscribe(
      FishermanServer.PubSub,
      FishermanServer.NotificationPublisher.channel_name(user_id)
    )

    # Start live feed polling from current timestamp
    first_ts = curr_dt |> DateTime.to_unix(:millisecond)
    state = refresh_feed_state(first_ts, curr_dt, user_id)
    {:ok, assign(socket, state: state)}
  end

  @doc """
  Subscriber callback for postgres notify messages
  """
  def handle_info(
        {:notify, %{"command_timestamp" => cmd_dt, "user_id" => user_id} = _notif},
        socket
      ) do
    # Pull feed records since time of executed command in notification
    first_ts = socket.assigns.state.row_info.first_ts
    state = refresh_feed_state(first_ts, cmd_dt, user_id)
    {:noreply, assign(socket, state: state)}
  end

  @doc """
  Query for records since the given timestamp
  """
  def refresh_feed_state(first_ts, _curr_dt, user_id) do
    latest_ts = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
    {:ok, user_uuid} = Ecto.UUID.dump(user_id)
    first_dt = first_ts |> DateTime.from_unix!(:millisecond)

    %{
      records: DB.Query.shell_records_since_dt(first_dt, user_uuid),
      row_info: %{
        latest_ts: latest_ts,
        first_ts: first_ts,
        num_rows: calc_ticks(latest_ts, first_ts, @time_incr),
        row_height: @row_height,
        pid_col_width: @pid_col_width,
        time_incr: @time_incr,
        min_record_height: @min_record_height
      }
    }
  end

  defp calc_ticks(latest_ts, first_ts, time_incr) do
    delta = abs(first_ts - latest_ts)
    div(delta, time_incr) |> max(@min_rows)
  end

  defp active_shells(records) do
    records
    |> Enum.map(& &1.pid)
    |> Enum.uniq()
    |> Enum.sort()
  end
end
