defmodule FishermanServerWeb.Live.ShellRecordsTable.TimeAxisComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.LiveComponent

  @impl
  def render(assigns) do
    ~L"""
    <div style="width: <%= @row_info.time_axis_width %>rem">

      <%= for ts_tick <- 1..@row_info.num_rows do %>
        <div style="height: <%= @row_info.row_height %>rem">
          <%= @row_info.first_ts + ts_tick * @row_info.time_incr  %>
        </div>
      <% end %>

    </div>
    """
  end
end
