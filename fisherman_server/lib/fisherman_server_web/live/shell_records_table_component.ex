defmodule FishermanServerWeb.Live.ShellRecordsTableComponent do
  @moduledoc """
  Container for shell records live feed table view.
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <!-- hooks -->
      <div phx-hook="ScrollAdjust"/>

      <!-- headers -->
      <div class="flexbox-wrapper">
        <div class="timestamp-axis">
          <h3 style="text-align: center"> Time (UTC) </h3>
        </div>
        <section class="swimlanes fluid-group scrollable" id="pid-axis">
          <%= for pid <- @pids do %>
            <div class="swimlanes__title">
              <h3 style="text-align:center">PID <%= pid %></h3>
            </div>
          <% end %>
        </section>
      </div>

      <!-- columns -->
      <div class="flexbox-wrapper">
        <div id="time-axis" class="vertical-scrollbox scrollable timestamp-axis">
          <%= live_component @socket,
            FishermanServerWeb.Live.ShellRecordsTable.TimeAxisComponent,
            row_info: @row_info %>
        </div>
        <div class="vertical-scrollbox fluid-group">
          <section class="swimlanes scrollable" id="shellfeed-content">
            <%= for pid <- @pids do %>
              <%= live_component @socket,
                FishermanServerWeb.Live.ShellRecordsTable.PidColumnComponent,
                pid: pid,
                row_info: @row_info,
                records: @records |> Enum.filter(&pid==&1.pid) %>
            <% end %>
          </section>
        </div>
      </div>
    """
  end
end
