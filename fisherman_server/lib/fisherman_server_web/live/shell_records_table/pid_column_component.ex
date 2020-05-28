defmodule FishermanServerWeb.Live.ShellRecordsTable.PidColumnComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.LiveComponent

  def render(assigns) do
    # TODO move any static styling to CSS file 
    ~L"""
    <style>
      .livetail-table {
        width: <%= @row_info.pid_col_width %>rem;
        table-layout: fixed;
        position: relative;
      }
    </style>

    <div style="display: inline-block">
      <table class="livetail-table">
        <tr>
          <th style="text-align:center">PID <%= @pid.name %></th>
        </tr>
        <%= for _ <- 1..@row_info.num_rows do %>
          <tr>
            <td>
            </td>
          </tr>
        <% end %>
      </table>
      <%= for record <- @records do %>
        <%= live_component @socket,
          FishermanServerWeb.Live.ShellRecordsTable.ShellRecordComponent,
          record: record,
          y_offset: calc_y_offset(record, @row_info),
          height: calc_height(record, @row_info),
          pid_col_width: @row_info.pid_col_width,
          pid_color: @pid.color
        %> 
      <% end %>
    </div>
    """
  end

  defp calc_y_offset(record, row_info) do
    %{
      num_rows: num_rows,
      row_height: row_height,
      time_incr: time_incr,
      first_ts: first_ts
    } = row_info

    total_time_area = num_rows * time_incr
    total_col_area = num_rows * row_height

    ts_start_diff = abs(first_ts - get_in(record, ["new_row_data", "command_timestamp"]))
    ts_ratio = ts_start_diff / total_time_area
    ts_ratio * total_col_area
  end

  defp calc_height(record, row_info) do
    %{
      "new_row_data" => %{
        "command_timestamp" => command_timestamp,
        "error_timestamp" => error_timestamp
      }
    } = record

    %{
      num_rows: num_rows,
      row_height: row_height,
      time_incr: time_incr
    } = row_info

    total_time_area = num_rows * time_incr
    total_col_area = num_rows * row_height

    record_time_area = error_timestamp - command_timestamp
    area_ratio = record_time_area / total_time_area
    area_ratio * total_col_area
  end
end
