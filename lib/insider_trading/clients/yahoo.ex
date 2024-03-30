defmodule InsiderTrading.Clients.Yahoo do
  alias InsiderTrading.Clients.Helpers

  @base_url "https://query2.finance.yahoo.com"
  @cookies_url "https://fc.yahoo.com"
  @crumb_url "/v1/test/getcrumb"
  @user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36"

  def get_ticker_historical_prices(ticker, start_date, end_date) do
    Helpers.get([], historical_endpoint(ticker, start_date, end_date))
  end

  def get_shares_outstanding(ticker) do
    {req_headers, crumb} = prepare_request_headers()
    Helpers.get(req_headers, outstanding_endpoint(ticker, crumb))
  end

  defp prepare_request_headers() do
    with {:ok, %HTTPoison.Response{headers: headers}} <-
           HTTPoison.get(@cookies_url),
         {:ok, cookie} <- get_cookie(headers),
         {:ok, crumb} <- get_crum_value(cookie) do
      {[{"Cookie", cookie}, {"User-agent", @user_agent}], crumb}
    else
      _ ->
        {:error, :failed_call_api}
    end
  end

  defp get_crum_value(cookie) do
    endpoint = "#{@base_url}#{@crumb_url}"
    req_headers = [{"Cookie", cookie}, {"User-agent", @user_agent}]
    Helpers.get(req_headers, endpoint)
  end

  defp get_cookie(headers) do
    {"Set-Cookie", req_cookie} = Enum.find(headers, &(elem(&1, 0) === "Set-Cookie"))

    cookie =
      req_cookie
      |> String.split(";")
      |> hd()

    {:ok, cookie}
  end

  defp historical_endpoint(ticker, start_date, end_date),
    do:
      "#{@base_url}/v7/finance/download/#{ticker}?period1=#{start_date}&period2=#{end_date}&interval=1d&events=history&includeAdjustedClose=true"

  defp outstanding_endpoint(ticker, crumb),
    do: "#{@base_url}/v7/finance/options/#{ticker}?crumb=#{crumb}"
end
