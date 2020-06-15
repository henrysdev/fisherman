defmodule FishermanServerWeb.Live.RelativeShellsTable.PIDControlComponent do
  @moduledoc """
  Component for a PID header with controls for viewing
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="grid-cell">
      PID <%= @pid %>
      <div class="flexbox-wrapper">
        <div>
          Hide
          <input class="fluid-group"
            type="checkbox"
            phx-click="toggle_pid_hide"
            phx-value-pid=<%= @pid %>>
        </div>
      </div>
    </div>
    """
  end
end
