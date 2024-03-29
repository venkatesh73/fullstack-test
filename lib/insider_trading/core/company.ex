defmodule InsiderTrading.Core.Company do
  @derive Jason.Encoder
  defstruct name: "",
            ticker: "",
            cik: ""
end
