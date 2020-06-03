defmodule FishermanServerWeb.Live.ShellRecordsTable.PidColumnComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.LiveComponent

  @impl
  def render(assigns) do
    ~L"""
    <div class="swimlanes__column">

      <%= for record <- @records do %>
        <%= live_component @socket,
          FishermanServerWeb.Live.ShellRecordsTable.ShellRecordComponent,
          record: record,
          y_offset: calc_y_offset(record, @row_info),
          height: calc_height(record, @row_info),
          pid_col_width: @row_info.pid_col_width
        %> 
      <% end %>

    </div>
    """
  end

  def calc_y_offset(record, row_info) do
    %{
      num_rows: num_rows,
      row_height: row_height,
      time_incr: time_incr,
      first_ts: first_ts
    } = row_info

    command_ts = record.command_timestamp |> DateTime.to_unix(:millisecond)
    total_time_area = num_rows * time_incr
    total_col_area = num_rows * row_height

    ts_start_diff = abs(first_ts - command_ts)
    ts_ratio = ts_start_diff / total_time_area
    ts_ratio * total_col_area
  end

  def calc_height(record, row_info) do
    %{
      num_rows: num_rows,
      row_height: row_height,
      time_incr: time_incr
    } = row_info

    command_ts = record.command_timestamp |> DateTime.to_unix(:millisecond)
    error_ts = record.error_timestamp |> DateTime.to_unix(:millisecond)

    total_time_area = num_rows * time_incr
    total_col_area = num_rows * row_height

    record_time_area = error_ts - command_ts
    area_ratio = record_time_area / total_time_area
    area_ratio * total_col_area
  end
end
