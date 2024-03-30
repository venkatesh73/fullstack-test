defmodule InsiderTrading.Core.InsiderTrade do
  alias InsiderTrading.Core.Company
  alias InsiderTrading.Core.Form

  @derive Jason.Encoder
  defstruct data: %Company{},
            forms: %Form{}

  def new(company, form) do
    %__MODULE__{
      data: company,
      forms: form
    }
  end

  def parse() do
  end
end
