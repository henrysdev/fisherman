defmodule FishermanServerWeb.Live.RelativeShellsTable.ShellRecordComponent do
  @moduledoc """
  Component for a rendered shell record object
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div
      class="grid-cell"
      style="grid-row: <%= @x_idx %>/<%= @x_idx + @fill_size %>;
             grid-column: <%= @y_idx %>;
             background-color: <%= FishermanServer.Utils.pick_color(@record) %>;"
      phx-click="open_slideout" phx-value-record_id=<%= @record.uuid %> >
        $ <code><%= @record.command %></code>
    </div>
    """
  end
end
