defmodule InsiderTradingWeb.Api.TradeInfoController do
  use InsiderTradingWeb, :controller

  def index(conn, %{"ticker" => ticker} = _params) do
    case InsiderTrading.TradeInfo.get_by_ticker(ticker) do
      {:ok, data} ->
        render(conn, :index, %{data: data})

      {:error, _} ->
        render(conn, :index, %{})
    end
  end
end
