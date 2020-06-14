defmodule FishermanServerWeb.Live.RelativeShellsTable do
  @moduledoc """
  Entry point for relative shell feed liveview. Mounts a liveview that
  registers as a subscriber to the user whos history is being
  recorded. Displays a relative table view of commands.

  The subscriber gets a change-data-capture notify event
  when a new shell record for a relevant user has been inserted,
  at which point the view is refreshed.
  """
  use Phoenix.LiveView

  alias FishermanServer.{
    Query,
    ShellPIDStore,
    Sorts,
    Utils
  }

  def render(assigns) do
    ~L"""
    <%= live_component @socket,
        FishermanServerWeb.Live.RelativeShellsTable.RelativeShellsTableComponent,
        table_matrix: @state.table_matrix,
        pids: @state.pids,
        records: @state.records,
        row_info: @state.row_info %>
    """
  end

  def mount(_params, %{"user_id" => user_id, "from_ts" => curr_dt} = _session, socket) do
    # On mount, subscribe to appropriate feed
    Phoenix.PubSub.subscribe(
      FishermanServer.PubSub,
      FishermanServer.NotificationPublisher.channel_name(user_id)
    )

    # Use shell pid store agent to persist pid order across requests 
    {:ok, sh_pid_store} = ShellPIDStore.start_link([])
    socket = assign(socket, :sh_pid_store, sh_pid_store)

    # Start live feed polling from current timestamp
    first_ts = curr_dt |> DateTime.to_unix(:millisecond)
    state = refresh_feed_state(first_ts, curr_dt, user_id, sh_pid_store)
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
    sh_pid_store = socket.assigns.sh_pid_store
    state = refresh_feed_state(first_ts, cmd_dt, user_id, sh_pid_store)
    {:noreply, assign(socket, state: state)}
  end

  @doc """
  Query for records since the given timestamp
  """
  def refresh_feed_state(first_ts, _curr_dt, user_id, sh_pid_store) do
    latest_ts = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
    {:ok, user_uuid} = Ecto.UUID.dump(user_id)

    first_dt = first_ts |> DateTime.from_unix!(:millisecond)

    records =
      Query.shell_records_since_dt(first_dt, user_uuid)
      |> Enum.sort(fn a, b ->
        case DateTime.compare(a.command_timestamp, b.command_timestamp) do
          :gt -> false
          _ -> true
        end
      end)

    record_pids = Utils.extract_pids(records)
    pids = ShellPIDStore.update_and_get_pids(sh_pid_store, record_pids)
    {table_matrix, record_lookup} = Sorts.build_table_matrix(records, pids)

    %{
      table_matrix: table_matrix,
      pids: record_pids,
      records: record_lookup,
      row_info: %{
        latest_ts: latest_ts,
        first_ts: first_ts,
        num_rows: length(records)
      }
    }
  end
end
