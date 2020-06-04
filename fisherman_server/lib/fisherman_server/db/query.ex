defmodule FishermanServer.DB.Query do
  import Ecto.Query, warn: false

  alias FishermanServer.Repo

  # TODO unit tests
  def shell_records_since_dt(datetime, user_id) do
    query =
      from sh in FishermanServer.ShellRecord,
        where:
          sh.command_timestamp >=
            datetime_add(^datetime, 0, "second") and
            sh.user_id == ^user_id

    Repo.all(query)
  end
end
