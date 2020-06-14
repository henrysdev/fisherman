defmodule FishermanServerWeb.Live.RelativeShellsTable.RelativeShellsTableComponent do
  @moduledoc """
  Component for relative shell records
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <!-- Sticky Headers -->
      <div class="grid"
        style="grid-template-columns: repeat(<%= length(@pids) %>, minmax(10rem, 400rem))">
        <%= for pid <- @pids do %>
          <div class="grid-cell"> PID <%= pid %> </div>
        <% end %>
      </div>

      <!-- Grid Content -->
      <div class="grid"
        style="grid-template-columns: repeat(<%= length(@pids) %>, minmax(10rem, 400rem))">
        <%= for row_idx <- 0..@row_info.num_rows * 2 do %>
            <%= for {pid, col_idx} <- Enum.with_index(@pids) do %>
              <%= case row_content(@table_matrix, pid, row_idx) do %>
                <% {:start, cell_info} -> %>
                  <%= live_component @socket,
                    FishermanServerWeb.Live.RelativeShellsTable.ShellRecordComponent,
                    record: Map.get(@records, cell_info.record_id),
                    fill_size: cell_info.fill_size,
                    x_idx: row_idx + 2,
                    y_idx: col_idx + 1
                  %>
                <% :fill -> %>
                <% _nofill -> %>
                  <div class="grid-cell"
                        style="grid-row: <%= row_idx + 2 %>;
                        grid-column: <%= col_idx + 1 %> ">
                    <br/>
                  </div>
              <% end %>
            <% end %>
        <% end %>
      </div>
    """
  end

  defp row_content(cell_map, pid, order_idx) do
    fill_lookup = cell_map |> Map.get(pid)

    case Map.get(fill_lookup, order_idx) do
      {:start, cell_info} -> {:start, cell_info}
      :fill -> :fill
      _ -> nil
    end
  end
end
