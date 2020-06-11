defmodule FishermanServerWeb.Live.RelativeShellsTable.RelativeShellsTableComponent do
  @moduledoc """
  Component for relative shell records
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <table border="1" id="relative-shells-table">

        <tr>
          <%= for pid <- @pids do %>
            <th>PID <%= pid %></th>
          <% end %>
        </tr>

        <!-- FFT: are we iterating by row idx or record? -->
        <%= for idx <- 0..@row_info.num_rows * 2 do %>
          <tr>
            <%= for pid <- @pids do %>
              <%= case row_content(@table_matrix, pid, idx) do %>
                <% {:start, cell_info} -> %>
                  <td rowspan="<%= cell_info.fill_size %>" style="background-color: yellow">
                    <%= Map.get(@records, cell_info.record_id).command %>
                  </td>
                <% :fill -> %>
                <% _nofill -> %>
                  <td>
                  </td>
              <% end %>
            <% end %>
          </tr>
        <% end %>
      </table>
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
