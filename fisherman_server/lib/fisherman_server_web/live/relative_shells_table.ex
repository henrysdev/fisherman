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
    Sorts
  }

  def render(assigns) do
    ~L"""
    <%= live_component @socket,
        FishermanServerWeb.Live.RelativeShellsTable.RelativeShellsTableComponent,
        table_matrix: @table_matrix,
        pids: @pids,
        record_lookup: @record_lookup %>

    <%= if @slideout_record != nil do %>
      <%= live_component @socket,
        FishermanServerWeb.Live.RelativeShellsTable.ShellRecordInspectorComponent,
        record: @slideout_record
      %>
    <% end %>
    """
  end

  def mount(
        _params,
        %{"user_id" => user_id, "from_ts" => from_ts} = _session,
        socket
      ) do
    # Subscribe to appropriate feed
    Phoenix.PubSub.subscribe(
      FishermanServer.PubSub,
      FishermanServer.NotificationPublisher.channel_name(user_id)
    )

    # Initialize socket assigns state
    init_state = [
      slideout_record: nil,
      user_id: user_id,
      pids: [],
      first_ts: DateTime.to_unix(from_ts, :millisecond),
      hidden_pids: MapSet.new()
    ]

    socket =
      socket
      |> assign(init_state)
      |> refresh_records()
      |> refresh_pids()
      |> refresh_matrix_and_lookup()

    {:ok, socket}
  end

  @doc """
  Subscriber callback for incoming shell messages
  """
  def handle_info(
        {:notify, %{"command_timestamp" => _cmd_dt, "user_id" => _user_id} = _notif},
        socket
      ) do
    socket =
      socket
      |> refresh_records()
      |> refresh_pids()
      |> refresh_matrix_and_lookup()

    {:noreply, socket}
  end

  @doc """
  Callback to inspect a selected shell history event
  """
  def handle_event(
        "slideout_inspector",
        %{"record_id" => record_id},
        %{assigns: %{record_lookup: record_lookup}} = socket
      ) do
    {:noreply, assign(socket, slideout_record: Map.get(record_lookup, record_id))}
  end

  @doc """
  Callback to inspect a selected shell history event
  """
  def handle_event(
        "toggle_pid_hide",
        %{"pid" => pid},
        %{assigns: %{hidden_pids: hidden_pids}} = socket
      ) do
    hidden_pids =
      if MapSet.member?(hidden_pids, pid) do
        MapSet.delete(hidden_pids, pid)
      else
        MapSet.put(hidden_pids, pid)
      end

    socket =
      socket
      |> assign(hidden_pids: hidden_pids)
      |> refresh_pids()

    {:noreply, socket}
  end

  defp refresh_records(%{assigns: %{user_id: user_id, first_ts: first_ts}} = socket) do
    {:ok, user_uuid} = Ecto.UUID.dump(user_id)
    since_dt = DateTime.from_unix!(first_ts, :millisecond)

    records =
      Query.shell_records_since_dt(since_dt, user_uuid)
      |> Enum.sort(fn a, b ->
        case DateTime.compare(a.command_timestamp, b.command_timestamp) do
          :gt -> false
          _ -> true
        end
      end)

    assign(socket, records: records)
  end

  defp refresh_pids(
         %{assigns: %{records: records, pids: _old_pids, hidden_pids: hidden_pids}} = socket
       ) do
    pids =
      records
      |> Enum.map(& &1.pid)
      |> Enum.uniq()
      |> Enum.reject(&MapSet.member?(hidden_pids, &1))

    assign(socket, pids: pids)
  end

  defp refresh_matrix_and_lookup(%{assigns: %{records: records, pids: pids}} = socket) do
    {table_matrix, record_lookup} = Sorts.build_table_matrix(records, pids)

    socket
    |> assign(table_matrix: table_matrix)
    |> assign(record_lookup: record_lookup)
  end
end
