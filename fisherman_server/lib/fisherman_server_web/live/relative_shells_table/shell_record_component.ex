defmodule FishermanServerWeb.Live.RelativeShellsTable.ShellRecordComponent do
  @moduledoc """
  Component for a rendered shell record object
  """
  use Phoenix.LiveComponent

  @no_error_color "#a0cf93"
  @error_color "#f79292"

  def render(assigns) do
    ~L"""
    <div
      class="grid-cell"
      style="grid-row: <%= @x_idx %>/<%= @x_idx + @fill_size %>;
             grid-column: <%= @y_idx %>;
             background-color: <%= pick_color(@record) %>;"
      phx-click="slideout_inspector" phx-value-record_id=<%= @record.uuid %> >
        $ <code><%= @record.command %></code>
    </div>
    """
  end

  @doc """
  Determines color of the shell record background on basis
  of if the command produced an error or not
  """
  def pick_color(%{error: error}) do
    if Enum.member?(["", nil], error) do
      @no_error_color
    else
      @error_color
    end
  end
end
