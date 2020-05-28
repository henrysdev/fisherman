defmodule FishermanServerWeb.Live.ShellRecordsTableComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.LiveComponent

  @impl
  def render(assigns) do
    # TODO move any static styling to CSS file
    ~L"""
    <style>
      td {
        position: relative;
        height: 5rem;
      }
      table, th, td {
        border: 1px solid black;
        border-collapse: collapse;
      }
    </style>

    <nobr>
      <!-- time column -->
      <%= live_component @socket,
        FishermanServerWeb.Live.ShellRecordsTable.TimeAxisComponent,
        row_info: @row_info %>
      <!-- pid columns -->
      <%= for pid <- @pids do %>
        <%= live_component @socket,
          FishermanServerWeb.Live.ShellRecordsTable.PidColumnComponent,
          pid: pid,
          row_info: @row_info,
          records: @records |> Enum.filter(&pid.name==get_in(&1, ["new_row_data", "pid"])) %>
      <% end %>
    </nobr>
    """
  end
end
