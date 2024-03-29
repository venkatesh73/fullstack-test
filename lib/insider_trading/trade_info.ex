defmodule InsiderTrading.TradeInfo do
  alias InsiderTrading.Clients.Sec
  alias InsiderTrading.Core.Tickers

  def get_by_ticker(ticker) do
    with {:ok, tickers_exchange} <- Sec.get_tickers_exchange(),
         {:ok, cik} <- get_ticker_cik(tickers_exchange, ticker),
         {:ok, trade_info} <- Sec.get_trade_by_cik(cik),
         insider_info <- get_insider_trade_info(trade_info) do
      {:ok, insider_info}
    else
      [] -> {:error, :no_matching_ticker}
      error -> error
    end
  end

  defp get_ticker_cik(tickers_exchange, ticker) do
    with {:ok, formated_tickers} <- Tickers.parse(tickers_exchange) do
      match_and_get_ticker_cik(formated_tickers, ticker)
    end
  end

  defp match_and_get_ticker_cik(tickers_exchange, ticker) do
    case Enum.filter(tickers_exchange, &(&1.ticker == String.upcase(ticker))) do
      [%Tickers{cik: cik}] ->
        {:ok, cik}

      [] ->
        {:error, :no_ticker_matches}
    end
  end

  defp get_insider_trade_info(trade_info) do
    Enum.map(trade_info, &Sec.get_company_forms(&1))
  end
end
