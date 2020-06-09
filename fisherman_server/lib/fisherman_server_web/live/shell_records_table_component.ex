defmodule FishermanServerWeb.Live.ShellRecordsTableComponent do
  @moduledoc """
  Container for shell records live feed table view.
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div>

      <!-- column headers -->
      <section class="swimlanes">
        <div style="text-align: center; width: <%= @row_info.time_axis_width %>rem">
          Time (UTC)
        </div>
        <%= for pid <- @pids do %>
          <div class="swimlanes__title">
            <h3 style="text-align:center">PID <%= pid %></h3>
          </div>
        <% end %>
      </section>

      <!-- columns -->
        <section class="swimlanes"
          style="
          overflow:auto
          max-height:80vh;
          height:100%">
        <%= live_component @socket,
              FishermanServerWeb.Live.ShellRecordsTable.TimeAxisComponent,
              row_info: @row_info %>
        <%= for pid <- @pids do %>
          <%= live_component @socket,
            FishermanServerWeb.Live.ShellRecordsTable.PidColumnComponent,
            pid: pid,
            row_info: @row_info,
            records: @records |> Enum.filter(&pid==&1.pid) %>
        <% end %>
        </section>

    </div>
    """
  end
end
