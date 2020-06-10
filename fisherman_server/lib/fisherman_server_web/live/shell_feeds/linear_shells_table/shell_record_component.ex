defmodule FishermanServerWeb.Live.LinearShellsTable.ShellRecordComponent do
  @moduledoc """
  Component for a rendered shell record object
  """
  use Phoenix.LiveComponent

  @no_error_color "#a0cf93"
  @error_color "#f79292"

  def render(assigns) do
    ~L"""
    <div class="shell-record"
      style="top: <%= @y_offset %>rem;
          height: <%= @height %>rem;
          background-color: <%= pick_color(@record) %>;"
      id="<%= @record.uuid %>"
    >
      <strong><%= @record.command %></strong>
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
