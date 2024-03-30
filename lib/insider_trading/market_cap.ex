defmodule InsiderTrading.MarketCap do
  alias InsiderTrading.Clients.Yahoo
  alias NimbleCSV.RFC4180, as: CSV

  @period_in_day_to_search_historical_share_close_prices -183

  def get_market_cap_values(ticker) do
    with {:ok, shares_outstadning} <- Yahoo.get_shares_outstanding(ticker),
         outstanding_data <- parse_shares_outstanding(shares_outstadning),
         historical_share <- get_historical_share_prices(ticker) do
      Enum.map(historical_share, fn share ->
        calculate_and_add_market_cap_to_map(share, outstanding_data)
      end)
    end
  end

  defp parse_shares_outstanding(shares_outstadning) do
    shares_outstadning
    |> Jason.decode!()
    |> Map.get("optionChain", %{})
    |> Map.get("result", [])
    |> List.first(%{})
    |> Map.get("quote", %{})
    |> Map.get("sharesOutstanding", 0)
  end

  defp get_historical_share_prices(ticker) do
    period_start =
      DateTime.utc_now()
      |> DateTime.add(@period_in_day_to_search_historical_share_close_prices, :day)
      |> DateTime.to_unix()

    period_end = DateTime.to_unix(DateTime.utc_now())

    with {:ok, historical_csv} <-
           Yahoo.get_ticker_historical_prices(ticker, period_start, period_end) do
      historical_csv
      |> CSV.parse_string()
      |> Enum.map(fn item -> filter_date_and_close_share_prices(item) end)
    end
  end

  defp calculate_and_add_market_cap_to_map(share, outstanding_data) do
    share_close_price = String.to_float(share[:close])
    market_cap = share_close_price * outstanding_data
    Map.put(share, :market_cap, market_cap)
  end

  defp filter_date_and_close_share_prices(share_prices_values) do
    [date, _open, _high, _low, close, _adj_close, _volume] = share_prices_values
    %{date: date, close: close}
  end
end
