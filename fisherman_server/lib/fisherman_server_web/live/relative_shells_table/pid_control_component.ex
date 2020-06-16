defmodule FishermanServerWeb.Live.RelativeShellsTable.PIDControlComponent do
  @moduledoc """
  Component for a PID header with controls for viewing
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="grid-header">
      <div class="pid-hide-btn"
        phx-click="hide_pid"
        phx-value-pid=<%= @pid %>>
          🚫
      </div>
      <strong> PID <%= @pid %> </strong>
    </div>
    """
  end
end
