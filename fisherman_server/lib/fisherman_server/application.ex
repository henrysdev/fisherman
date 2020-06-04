defmodule FishermanServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      FishermanServer.Repo,
      # Start the Telemetry supervisor
      FishermanServerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FishermanServer.PubSub},
      # Start the Endpoint (http/https)
      FishermanServerWeb.Endpoint,
      # Start the NotificationPublisher
      {FishermanServer.Pubsub.NotificationPublisher, "shell_record_inserts"}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FishermanServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FishermanServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
