defmodule FishermanServer.Repo do
  use Ecto.Repo,
    otp_app: :fisherman_server,
    adapter: Ecto.Adapters.Postgres
end
