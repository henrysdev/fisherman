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

  @doc """
  Encode the given datetime to be url safe. Use current utc time if not specified
  """
  def encode_url_datetime(datetime \\ DateTime.utc_now()) do
    datetime
    |> DateTime.to_unix(:millisecond)
    |> to_string()
  end

  def decode_url_datetime(url_datetime) do
    {millis, _} = Integer.parse(url_datetime)
    DateTime.from_unix!(millis, :millisecond)
  end

  @doc """
  Determines color of the shell record background on basis
  of if the command produced an error or not
  """
  @no_error_color "#a0cf93"
  @error_color "#f79292"

  def pick_color(%{error: error}) do
    if Enum.member?(["", nil], error) do
      @no_error_color
    else
      @error_color
    end
  end
end
