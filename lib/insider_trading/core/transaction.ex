defmodule InsiderTrading.Core.Transaction do
  @derive Jason.Encoder
  defstruct date: "",
            shares_amount: 0,
            per_share_price: 0.0,
            value: 0.0,
            market_cap_percent: 0.0,
            market_cap_value: 0.0

  def new(date, shares_amount, per_share_price, value, market_cap_percent, market_cap_value) do
    %__MODULE__{
      date: date,
      shares_amount: shares_amount,
      per_share_price: per_share_price,
      value: value,
      market_cap_percent: market_cap_percent,
      market_cap_value: market_cap_value
    }
  end

  def parse(_ownership) do
    new("", "", "", "", "", "")
  end
end
