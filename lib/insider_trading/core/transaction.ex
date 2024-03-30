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

  def parse(ownership, _marketcap) do
    _non_derivatives_details = non_derivative_info(ownership)
    _derivatives_details = derivative_info(ownership)

    new("", "", "", "", "", "")
  end

  defp non_derivative_info(ownership) do
    case Map.get(ownership, "nonDerivativeTable") do
      nil ->
        %{}

      non_der ->
        non_der
        |> Map.get("nonDerivativeTransaction")
        |> Enum.map(fn trans ->
          trans
          |> Map.get("transactionAmounts", %{})
          |> Map.get("transactionShares", %{})
          |> Map.get("value", 0)
          |> convert_string_to_number()
        end)
    end
  end

  defp derivative_info(ownership) do
    case Map.get(ownership, "derivativeTable") do
      nil ->
        %{}

      der ->
        Map.get(der, "derivativeTransaction")

        der
        |> Map.get("derivativeTransaction")
        |> Enum.map(fn trans ->
          trans
          |> Map.get("transactionAmounts", %{})
          |> Map.get("transactionPricePerShare", %{})
          |> Map.get("value", 0)
          |> convert_string_to_number()
        end)
    end
  end

  defp convert_string_to_number(str_value) do
    case number_type(str_value) do
      :integer -> String.to_integer(str_value)
      :float -> String.to_float(str_value)
      _ -> 0
    end
  end

  defp number_type(str) when is_binary(str) do
    cond do
      String.match?(str, ~r/^-?\d+$/) -> :integer
      String.match?(str, ~r/^-?\d+\.\d+$/) -> :float
      true -> 0
    end
  end

  defp number_type(str), do: str
end
