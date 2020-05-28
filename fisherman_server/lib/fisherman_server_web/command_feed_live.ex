defmodule FishermanServerWeb.CommandFeedLive do
  use Phoenix.LiveView

  @ex_state %{
    user: "henry.warren",
    pids: [
      %{
        name: "72508"
      },
      %{
        name: "41159"
      }
    ],
    records: [
      %FishermanServer.ShellRecord{
        command: "ssh -N -L abc.com user.last@abc",
        command_timestamp: ~U[2020-05-28 08:28:12.035000Z],
        error: "zsh: command not found: asd",
        error_timestamp: ~U[2020-05-28 08:28:12.095000Z],
        inserted_at: ~N[2020-05-28 08:28:12],
        pid: "72508",
        updated_at: ~N[2020-05-28 08:28:12],
        user_id: "453cecfe-d768-47fa-8f0b-0e42b179c612",
        uuid: "6b88399c-361b-4fc5-bdbd-3c56e7c3d889"
      },
      %FishermanServer.ShellRecord{
        command: "asdf",
        command_timestamp: ~U[2020-05-27 23:00:40.076000Z],
        error: "zsh: command not found: asdf",
        error_timestamp: ~U[2020-05-27 23:00:40.125000Z],
        inserted_at: ~N[2020-05-27 23:00:40],
        pid: "41159",
        updated_at: ~N[2020-05-27 23:00:40],
        user_id: "a261435a-34b4-4135-ab9f-cfea41eb59ed",
        uuid: "4506cfd5-cf13-4d08-a526-d72f52ac6749"
      }
    ],
    row_info: %{
      num_rows: 10,
      # (rem) height of a row in table
      row_height: 3.5,
      # (rem) width of a pid column in table
      pid_col_width: 20.0,
      # (ms) between each tick on time axis
      time_incr: 1000,
      # (unix millis) timestamp of first tick on time axis
      first_ts: 1_590_610_079_000,
      time_axis_width: 12
    }
  }

  def render(assigns) do
    ~L"""
    <%= live_component @socket,
        FishermanServerWeb.Live.ShellRecordsTableComponent,
        pids: @state.pids,
        records: @state.records,
        row_info: @state.row_info %>
    """
  end

  def mount(params, session, socket) do
    Phoenix.PubSub.subscribe(FishermanServer.PubSub, "shell_records")

    {:ok, assign(socket, state: @ex_state)}
  end

  @doc """
  Handles postgres insert shell record events
  """
  def handle_info({:new, msg}, socket) do
    # TODO
    # 1. Query DB for changes since last query
    # 2. Build expected state struct from DB records
    # 3. Render
    {:noreply, assign(socket, state: @ex_state)}
  end
end
