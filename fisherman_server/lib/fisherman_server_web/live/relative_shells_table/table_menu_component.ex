defmodule FishermanServerWeb.Live.RelativeShellsTable.TableMenuComponent do
  @moduledoc """
  Component for relative shell records
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <div class="table-menu">
        <div class="table-menu-header">
          <strong> ZSH Shell History </strong>
        </div>
        <div class="table-menu-content">
          <div>
            Time Range: TODO
          </div>
        </div>
      </div>
    """
  end
end
