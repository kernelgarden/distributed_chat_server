defmodule LobbyServer.QueryHelper do
  require Logger

  @spec query(binary(), [any()]) :: {:ok, [map()]} | {:error, any()}
  def query(sql, parameters \\ []) do
    try do
      LobbyServer.Repo
      |> Ecto.Adapters.SQL.query!(sql, parameters)
      |> parse_query()
    rescue
      e in ArgumentError ->
        Logger.error(fn -> "[QueryHelper] Mismatched arguments! - #{inspect(e)}" end)
        {:error, e}

      other ->
        Logger.error(fn -> "[QueryHelper] Error occured! - #{inspect(other)}" end)
        {:error, other}
    end
  end

  @spec parse_query(Mariaex.Result.t()) :: [map()]
  defp parse_query(result) do
    case result.num_rows > 0 do
      true -> do_parse_query(result)
      false -> []
    end
  end

  defp do_parse_query(result) do
    columns =
      result.columns
      |> Enum.map(fn column ->
        :"#{column}"
      end)

    result =
      result.rows
      |> Stream.map(&Stream.zip(columns, &1))
      |> Enum.map(&Enum.into(&1, %{}))

    result
  end
end
