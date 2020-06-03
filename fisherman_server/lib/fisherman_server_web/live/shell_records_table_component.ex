defmodule FishermanServerWeb.Live.ShellRecordsTableComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.LiveComponent

  @impl
  def render(assigns) do
    # TODO move any static styling to CSS file
    ~L"""
    <div>

      <!-- column headers -->
      <section class="swimlanes">
        <div style="text-align: center; width: <%= @row_info.time_axis_width %>rem">
          time (UTC)
        </div>
        <%= for pid <- @pids do %>
          <div class="swimlanes__title">
            <h3 style="text-align:center">PID <%= pid %></h3>
          </div>
        <% end %>
      </section>

      <!-- columns -->
      <section class="swimlanes"
        style="overflow:auto;
        max-height:100%;
        height: <%= @row_info.num_rows * @row_info.row_height %>rem">
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
