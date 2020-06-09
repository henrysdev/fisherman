defmodule FishermanServerWeb.Router do
  use FishermanServerWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Endpoints for web UI
  scope "/", FishermanServerWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/shellfeed", PageController, :shellfeed
  end

  # Endpoints for JSON API
  scope "/api", FishermanServerWeb do
    pipe_through :api

    # Resource endpoints for the user model
    scope "/user" do
      post "/", UserController, :create
    end

    # Resource endpoints for the shell message model
    scope "/shellmsg" do
      post "/", ShellMessageController, :create
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: FishermanServerWeb.Telemetry
    end
  end
end
