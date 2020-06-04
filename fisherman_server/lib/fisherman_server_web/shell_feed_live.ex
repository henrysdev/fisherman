defmodule FishermanServerWeb.ShellFeedLive do
  use Phoenix.LiveView

  alias FishermanServer.DB

  @notify_channel "notify_feed_refresh"
  @min_rows 3
  @min_record_height 2.5
  @row_height 3.5
  @pid_col_width 20.0
  # ms between each time axis tick
  @time_incr 5_000
  @time_axis_width 20

  def render(assigns) do
    ~L"""
    <%= live_component @socket,
        FishermanServerWeb.Live.ShellRecordsTableComponent,
        pids: @state.records |> Enum.map(&(&1.pid)) |> Enum.uniq(),
        records: @state.records,
        row_info: @state.row_info %>
    """
  end

  def mount(params, %{"user_id" => user_id, "from_ts" => curr_dt} = session, socket) do
    # On mount, subscribe to appropriate feed
    Phoenix.PubSub.subscribe(FishermanServer.PubSub, @notify_channel)

    # Start live feed polling from current timestamp
    first_ts = curr_dt |> DateTime.to_unix(:millisecond)
    state = refresh_feed_state(first_ts, curr_dt, user_id)

    {:ok, assign(socket, state: state)}
  end

  @doc """
  Subscriber callback for postgres notify messages
  """
  def handle_info(
        {:notify, %{"command_timestamp" => cmd_dt, "user_id" => user_id} = notif},
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
  defp refresh_feed_state(first_ts, curr_dt, user_id) do
    latest_ts = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
    {:ok, user_uuid} = Ecto.UUID.dump(user_id)
    first_dt = first_ts |> DateTime.from_unix!(:millisecond)
    records = DB.Query.shell_records_since_dt(first_dt, user_uuid)

    %{
      records: records,
      row_info: %{
        latest_ts: latest_ts,
        first_ts: first_ts,
        num_rows: calc_ticks(latest_ts, first_ts, @time_incr),
        row_height: @row_height,
        pid_col_width: @pid_col_width,
        time_incr: @time_incr,
        time_axis_width: @time_axis_width,
        min_record_height: @min_record_height
      }
    }
  end

  defp calc_ticks(latest_ts, first_ts, time_incr) do
    IO.inspect({:LATEST_TS, latest_ts})
    IO.inspect({:FIRST_TS, first_ts})
    delta = abs(first_ts - latest_ts)
    IO.inspect({:DELTA, delta})
    ticks = div(delta, time_incr) |> max(@min_rows)
    IO.inspect({:TICKS, ticks})
    ticks
  end
end
