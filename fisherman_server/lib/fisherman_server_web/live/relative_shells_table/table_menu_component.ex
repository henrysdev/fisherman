defmodule FishermanServerWeb.Live.RelativeShellsTable.TableMenuComponent do
  @moduledoc """
  Component for relative shell records
  """
  use Phoenix.LiveComponent
  use Phoenix.HTML

  def render(assigns) do
    # TODO break up into sub-components
    ~L"""
      <div class="table-menu">
        <div class="table-menu-header">
          <strong> ZSH Shell History </strong>
        </div>
        <div class="table-menu-content">

          <!-- Query Form -->
          <div class="table-query-builder">
            <form phx-submit="records_query">
              <!-- Time Range -->
              <fieldset>
                <legend>Jump to</legend>
                <%= datetime_select :query, :start_time, default: @start_time, builder: fn b -> %>
                  Date: <%= b.(:day, []) %> / <%= b.(:month, []) %> / <%= b.(:year, []) %>
                  Time: <%= b.(:hour, []) %> : <%= b.(:minute, []) %> : <%= b.(:second, []) %>
                <% end %>
              </fieldset>
              <fieldset>
                <legend>Options</legend>
                <div>
                  Include Errors
                  <%= checkbox :query, :include_errors, value: @include_errors %>
                </div>
              </fieldset>
              <%= submit "Update Chart", class: "query-submit-btn", phx_disable_with: "Submitting..." %>
            </form>
          </div>

          <!-- PID Hiding -->
          <%= if MapSet.size(@hidden_pids) > 0 do %>
            <div class="table-view-options">
              <div class="hidden-pids-group">
                Hidden PIDs (click to remove)
                <%= for pid <- @hidden_pids do %>
                  <button class="hidden-pid-btn"
                    phx-click="toggle_pid"
                    phx-value-pid=<%= pid %>>
                    <%= pid %>
                    ✕
                  </button>
                <% end %>
              </div>
            </div>
          <% end %>

        </div>
      </div>
    """
  end
end
