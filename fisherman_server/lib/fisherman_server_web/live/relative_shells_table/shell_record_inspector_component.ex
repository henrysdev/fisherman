defmodule FishermanServerWeb.Live.RelativeShellsTable.ShellRecordInspectorComponent do
  @moduledoc """
  Component for relative shell records
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <div class="shell-inspector"
          style="flex: <%= @slide_width%>">
        <div class="shell-inspector-header">
          <strong> Inspector </strong>
        </div>
        <div class="shell-inspector-content">
          <button class="shell-inspector-close-btn" phx-click="close_slideout">
            ✕
          </button>
          <div>
            Command: <code> <%= @record.command %></code>
          </div>
          <div>
            PID: <code> <%= @record.pid %></code>
          </div>
          <div>
            Started: <code> <%= @record.command_timestamp %></code>
          </div>
          <div>
            Ended: <code> <%= @record.error_timestamp %> </code>
          </div>
          <div>
            Execution Time: <code> TODO </code>
          </div>
          <%= if @record.error != "" do %>
            <div style="
              background-color:#f79292;
              border-radius: 0.4rem">
              Error: <code> <%= @record.error %></code>
            </div>
          <% end %>
          <div>
            UUID: <code> <%= @record.uuid %></code>
          </div>
        </div>
      </div>
    """
  end
end
