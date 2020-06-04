defmodule FishermanServerWeb.Live.ShellRecordsTable.TimeAxisComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="time-axis" width: <%= @row_info.time_axis_width %>>

      <%= for ts_tick <- 1..@row_info.num_rows do %>
        <div style="height: <%= @row_info.row_height %>rem; border: 1px black solid">
          <%= calc_label(@row_info, ts_tick) %>
        </div>
      <% end %>

    </div>
    """
  end

  defp calc_label(row_info, ts_tick) do
    (row_info.first_ts + ts_tick * row_info.time_incr) |> DateTime.from_unix!(:millisecond)
  end
end
