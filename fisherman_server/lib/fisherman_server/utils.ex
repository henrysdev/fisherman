defmodule FishermanServer.Utils do
  @moduledoc """
  Utils provides module-agnostic convenience functions
  """

  def unix_millis_to_dt(millis) when is_integer(millis) do
    (millis * 1_000)
    |> DateTime.from_unix!(:microsecond)
  end

  def unix_millis_to_dt(_), do: nil

  def pg_json_millis_to_dt(millis) do
    (millis <> "Z")
    |> Timex.Parse.DateTime.Parser.parse!("{ISO:Extended:Z}")
  end
end
