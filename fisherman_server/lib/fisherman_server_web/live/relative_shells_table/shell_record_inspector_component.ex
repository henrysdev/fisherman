defmodule FishermanServerWeb.Live.RelativeShellsTable.ShellRecordInspectorComponent do
  @moduledoc """
  Component for relative shell records
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <div class="shell-record-content">
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
        <div>
          Error: <code> <%= @record.error %></code>
        </div>
        <div>
          UUID: <code> <%= @record.uuid %></code>
        </div>
      </div>
    """
  end
end
