defmodule FishermanServerWeb.Live.ShellRecordsTable.TimeAxisComponent do
  @moduledoc """
  Component for the vertical time axis for the shell record table
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="time-axis" width: <%= @row_info.time_axis_width %>>

      <%= for ts_tick <- 1..@row_info.num_rows do %>
        <div class="time-tick" style="height: <%= @row_info.row_height %>rem">
          <%= calc_label(@row_info, ts_tick) %>
        </div>
      <% end %>

    </div>
    """
  end

  @doc """
  Calculates the time label for the given axis tick
  """
  def calc_label(row_info, ts_tick) do
    (row_info.first_ts + ts_tick * row_info.time_incr)
    |> DateTime.from_unix!(:millisecond)
  end
end
