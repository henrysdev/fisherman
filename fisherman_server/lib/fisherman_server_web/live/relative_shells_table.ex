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
  alias FishermanServerWeb.Router.Helpers, as: Routes

  alias FishermanServer.{
    Query,
    Sorts,
    Utils
  }

  def render(assigns) do
    ~L"""
      <div class="flexbox">

        <!-- Table Menu -->
        <%= live_component @socket,
            FishermanServerWeb.Live.RelativeShellsTable.TableMenuComponent,
            hidden_pids: @hidden_pids %>

        <!-- Table -->
        <%= live_component @socket,
            FishermanServerWeb.Live.RelativeShellsTable.RelativeShellsTableComponent,
            table_matrix: @table_matrix,
            pids: @pids,
            record_lookup: @record_lookup %>

        <!-- Inspector Slideout -->
        <%= if @slideout.record != nil do %>
          <%= live_component @socket,
            FishermanServerWeb.Live.RelativeShellsTable.ShellRecordInspectorComponent,
            record: @slideout.record,
            slide_width: @slideout.slide_width,
            expanded?: @slideout.expanded?
          %>
        <% end %>
      </div>
    """
  end

  def mount(_arg, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"user_id" => user_id, "start_time" => start_time}, _uri, socket) do
    # Subscribe to appropriate feed
    Phoenix.PubSub.subscribe(
      FishermanServer.PubSub,
      FishermanServer.NotificationPublisher.channel_name(user_id)
    )

    # Initialize socket assigns state
    init_state = [
      slideout: %{
        expanded?: false,
        slide_width: 1,
        record: nil
      },
      user_id: user_id,
      pids: [],
      start_time: Utils.decode_url_datetime(start_time),
      hidden_pids: MapSet.new()
    ]

    socket =
      socket
      |> assign(init_state)
      |> refresh_records()
      |> refresh_pids()
      |> refresh_matrix_and_lookup()

    {:noreply, socket}
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
  Callback to open the slideout inspector for the selected shell record
  """
  def handle_event(
        "open_slideout",
        %{"record_id" => record_id},
        %{assigns: %{record_lookup: record_lookup}} = socket
      ) do
    slideout = %{
      expanded?: true,
      slide_width: 1,
      record: Map.get(record_lookup, record_id)
    }

    {:noreply, assign(socket, slideout: slideout)}
  end

  @doc """
  Callback to close the slideout inspector
  """
  def handle_event(
        "close_slideout",
        _params,
        socket
      ) do
    slideout = %{
      expanded?: false,
      slide_width: 0,
      record: nil
    }

    {:noreply, assign(socket, slideout: slideout)}
  end

  @doc """
  Callback to hide a pid column
  """
  def handle_event(
        "toggle_pid",
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

  @doc """
  Callback to inspect a selected shell history event
  """
  def handle_event("records_query", _form_fields, socket) do
    # TODO use form fields
    {:noreply,
     push_redirect(
       socket,
       to:
         Routes.live_path(socket, __MODULE__, %{
           user_id: socket.assigns.user_id,
           start_time: Utils.encode_url_datetime()
         })
     )}
  end

  defp refresh_records(%{assigns: %{user_id: user_id, start_time: start_time}} = socket) do
    {:ok, user_uuid} = Ecto.UUID.dump(user_id)

    records =
      Query.shell_records_since_dt(start_time, user_uuid)
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
