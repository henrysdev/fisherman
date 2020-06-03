defmodule FishermanServerWeb.CommandFeedLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <%= live_component @socket,
        FishermanServerWeb.Live.ShellRecordsTableComponent,
        pids: @state.records |> Enum.map(&(&1.pid)) |> Enum.uniq(),
        records: @state.records,
        row_info: @state.row_info %>
    """
  end

  def mount(params, session, socket) do
    # On mount, subscribe to appropriate feed
    Phoenix.PubSub.subscribe(FishermanServer.PubSub, "shell_records")

    # Start live feed polling from current timestamp
    state = refresh_feed_state(DateTime.utc_now())

    {:ok, assign(socket, state: state)}
  end

  @doc """
  Handles postgres insert shell record events
  """
  def handle_info({:new, record_insert_notif}, socket) do
    IO.inspect({:OTHER_UTC, record_insert_notif |> get_in(["new_row_data", "command_timestamp"])})

    state =
      record_insert_notif
      |> get_in(["new_row_data", "command_timestamp"])
      # |> Timex.parse("2013-03-05", "{YYYY}-{0M}-{0D}")
      # |> DateTime.from_iso8601()
      |> DateTime.from_naive!(:millisecond, "Etc/UTC")
      |> refresh_feed_state()

    IO.inspect({:SUB_UTC, state})

    {:noreply, assign(socket, state: state)}
  end

  defp refresh_feed_state(past_bound_dt) do
    past_bound_ts = past_bound_dt |> DateTime.to_unix(:millisecond)
    records = FishermanServer.DB.Queries.shell_records_since_dt(past_bound_dt)

    %{
      records: records,
      row_info: %{
        num_rows: 10,
        row_height: 3.5,
        pid_col_width: 20.0,
        time_incr: 10_000,
        first_ts: past_bound_ts,
        time_axis_width: 20
      }
    }
  end
end
