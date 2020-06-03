defmodule FishermanServer.DB.Queries do
  import Ecto.Query, warn: false

  alias FishermanServer.Repo

  # TODO unit tests
  def shell_records_since_dt(datetime) do
    query =
      from sh in FishermanServer.ShellRecord,
        where:
          sh.command_timestamp >=
            datetime_add(^datetime, 0, "second")

    Repo.all(query)
  end
end
