defmodule InsiderTrading.Core.Tickers do
  @derive Jason.Encoder
  defstruct name: "",
            ticker: "",
            cik: ""

  def new(name, ticker, cik) do
    %__MODULE__{
      name: name,
      ticker: ticker,
      cik: cik
    }
  end

  def parse(%{"data" => data}) do
    {:ok, Enum.map(data, fn [cik, name, ticker, _] -> new(name, ticker, cik) end)}
  end

  def parse(_), do: {:error, :invalid_data}
end
