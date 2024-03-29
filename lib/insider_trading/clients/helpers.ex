defmodule InsiderTrading.Clients.Helpers do
  @spec get(any(), String.t()) ::
          {:ok, any()} | {:error, :unknown | String.t() | Plug.Conn.Status.code()}
  def get(headers, endpoint) do
    case HTTPoison.get(endpoint, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: code}} when code != 200 ->
        {:error, code}

      {:error, reason} ->
        {:error, "Request failed with reason #{reason}"}

      _ ->
        {:error, :unknown}
    end
  end
end
