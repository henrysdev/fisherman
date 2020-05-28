defmodule FishermanServerWeb.CommandFeedLive do
  use Phoenix.LiveView

  @ex_state %{
    user: "henry.warren",
    pids: [
      %{
        name: "32391",
        color: "green"
      },
      %{
        name: "12345",
        color: "red"
      }
    ],
    records: [
      %{
        "new_row_data" => %{
          "command" => "Fake Command!",
          "command_timestamp" => 1_590_610_080_000,
          "error" => "Fake Error!",
          "error_timestamp" => 1_590_610_081_000,
          "inserted_at" => 1_590_610_090_000,
          "pid" => "32391",
          "updated_at" => 1_590_610_090_000,
          "user_id" => "db16c7f006e3-4bbb-0e64-2ff2-939fc23f",
          "uuid" => "27e7ba88-1e1a-45d0-8e3a-b85badec6bcb"
        },
        "table" => "shell_records",
        "type" => "INSERT",
        "uuid" => "27e7ba88-1e1a-45d0-8e3a-b85badec6bcb"
      },
      %{
        "new_row_data" => %{
          "command" => "python -c \"raise ValueError('dasf')\"",
          "command_timestamp" => 1_590_610_083_000,
          "error" =>
            "Traceback (most recent call last):\n  File \"<string>\", line 1, in <module>\nValueError: dasf",
          "error_timestamp" => 1_590_610_084_000,
          "inserted_at" => 1_590_610_090_000,
          "pid" => "12345",
          "updated_at" => 1_590_610_090_000,
          "user_id" => "f32cf939-2ff2-46e0-bbb4-3e600f7c61bd",
          "uuid" => "34e7ba88-1e1a-45d0-8e3a-b85badec6bcb"
        },
        "table" => "shell_records",
        "type" => "INSERT",
        "uuid" => "34e7ba88-1e1a-45d0-8e3a-b85badec6bcb"
      }
    ],
    row_info: %{
      num_rows: 10,
      # (rem) height of a row in table
      row_height: 5.0,
      # (rem) width of a pid column in table
      pid_col_width: 20.0,
      # (ms) between each tick on time axis
      time_incr: 1000,
      # (unix millis) timestamp of first tick on time axis
      first_ts: 1_590_610_079_000
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
    IO.inspect({:mount_params, params})
    IO.inspect({:mount_session, session})
    IO.inspect({:mount_socket, socket})

    {:ok, assign(socket, state: @ex_state)}
  end

  def handle_info({:new, msg}, socket) do
    IO.inspect({:LIVEVIEW_RECV, msg})
    {:noreply, assign(socket, state: @ex_state)}
  end
end
