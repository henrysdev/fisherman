defmodule FishermanServerWeb.Live.ShellRecordsTable.ShellRecordComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.LiveComponent

  @impl
  def render(assigns) do
    ~L"""
    <div class="shell-record"
    style="top: <%= @y_offset %>rem;
          height: <%= @height %>rem;
          background-color: <%= pick_color(@record) %>;"
    id="<%= @record.uuid %>">
      <strong><%= @record.command %></strong>
    </div>
    """
  end

  # TODO pull colors out to constants file
  def pick_color(%{error: error}) do
    if Enum.member?(["", nil], error) do
      "#a0cf93"
    else
      "#f79292"
    end
  end
end
