defmodule FishermanServerWeb.CommandFeedLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <h2>
    Current temperature: <%= @temperature %>
    </h2>
    """
  end

  def mount(params, session, socket) do
    IO.inspect({:params, params})
    IO.inspect({:session, session})
    IO.inspect({:socket, socket})
    # Start update loop polling for new messages
    # if connected?(socket), do: Process.send_after(self(), :update, 1000)
    {:ok, assign(socket, temperature: "abc")}
  end

  # Refresh view
  def handle_info(:update, socket) do
    # Process.send_after(self(), :update, 1000)
    {:noreply, assign(socket, temperature: "def")}
  end
end
