defmodule FishermanServerWeb.Live.ShellRecordsTable.TimeAxisComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.LiveComponent

  def render(assigns) do
    # TODO move any static styling to CSS file 
    ~L"""
    <style>
      .time-axis {
        width: 12.0rem;
        table-layout: fixed;
        position: relative;
      }
    </style>

    <div style="display: inline-block">
      <table class="time-axis">
        <colgroup>
          <col span="1" class="time-axis">
        </colgroup>
        <tr>
          <th style="text-align:center">Time</th>
        </tr>
        <%= for ts_tick <- 1..@row_info.num_rows do %>
          <tr>
            <td>
              <%= @row_info.first_ts + ts_tick * @row_info.time_incr  %>
            </td>
          </tr>
        <% end %>
      </table>
    </div>
    """
  end
end
