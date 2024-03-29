defmodule InsiderTrading.Core.InsiderTrade do
  alias InsiderTrading.Core.Company
  alias InsiderTrading.Core.Form

  @derive Jason.Encoder
  defstruct data: %Company{},
            forms: %Form{}

  def new() do
  end

  def parse() do
  end
end
