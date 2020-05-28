defmodule FishermanServer.Utils do
  def unix_millis_to_dt(millis) when is_integer(millis) do
    (millis * 1_000)
    |> DateTime.from_unix!(:microsecond)
  end

  def unix_millis_to_dt(_), do: nil
end
