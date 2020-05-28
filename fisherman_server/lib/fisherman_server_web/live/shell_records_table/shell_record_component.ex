defmodule FishermanServerWeb.Live.ShellRecordsTable.ShellRecordComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.LiveComponent

  def render(assigns) do
    # TODO move any static styling to CSS file
    ~L"""
    <style>
      .shell-record {
        position: absolute;
        overflow: scroll;
        border-radius: 8px;
      }
    </style>

    <div class="shell-record"
    style="top: <%= @y_offset %>rem;
          width: <%= @pid_col_width %>rem;
          height: <%= @height %>rem;
          background-color: <%= @pid_color %>;"
    id="<%= Map.get(@record, "uuid") %>">
      <p><%= get_in(@record, ["new_row_data", "command"]) %></p>
    </div>
    """
  end
end
