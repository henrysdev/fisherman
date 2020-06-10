defmodule FishermanServerWeb.Live.RelativeShellsTableComponent do
  @moduledoc """
  Component for relative shell records
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <table border="1">

        <tr>
          <%= for pid <- @pids do %>
            <th>PID <%= pid %></th>
          <% end %>
        </tr>

        <%= for record <- @records |> Enum.with_index() do %>
          <tr>
            <%= for pid <- @pids do %>
              <td>PID <%= pid %></td>
            <% end %>
            <h1> <%= record.command %> </h1>
          </tr>
        <% end %>
      
          <!--
          <tr>
            <th>Month</th>
            <th>Savings</th>
            <th>Savings for holiday!</th>
          </tr>
          <tr>
            <td>January</td>
            <td>$100</td>
            <td rowspan="2">$50</td>
          </tr>
          <tr>
            <td>February</td>
            <td>$80</td>
          </tr>
          -->

      </table>
    """
  end

  def content_cell?(cell_map, order_idx, pid) do
    # Pre-calculate a sparse 2D map (pid -> set of idx that should be filled)
    # 1. Check if cell in set. if it is, do not put down a td tag. Otherwise, do
  end
end
