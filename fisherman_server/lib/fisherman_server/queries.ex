defmodule FishermanServer.Query do
  import Ecto.Query, warn: false

  alias FishermanServer.Repo

  def shell_records_between_ts() do
    query =
      from u in "shell_records",
        select: u.first_name

    # Send the query to the repository
    Repo.all(query)
  end
end
