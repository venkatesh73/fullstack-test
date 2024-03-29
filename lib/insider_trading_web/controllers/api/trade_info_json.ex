defmodule InsiderTradingWeb.Api.TradeInfoJSON do
  def index(%{data: data}) do
    %{response: data}
  end
end
