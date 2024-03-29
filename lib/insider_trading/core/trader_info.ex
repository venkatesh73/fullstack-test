defmodule InsiderTrading.Core.TraderInfo do
  @derive Jason.Encoder
  defstruct name: "",
            title: ""

  def new(name, title) do
    %__MODULE__{
      name: name,
      title: title
    }
  end

  def parse(trader_info) do
    owner = get_reporting_owner(trader_info)
    new(get_owner_name(owner), get_owner_title(owner))
  end

  defp get_reporting_owner(%{"reportingOwner" => owner}) do
    case is_list(owner) do
      true -> hd(owner)
      false -> owner
    end
  end

  defp get_reporting_owner(_), do: %{}

  defp get_owner_name(owner) do
    owner
    |> Map.get("reportingOwnerId", %{})
    |> Map.get("rptOwnerName", "")
  end

  defp get_owner_title(owner) do
    owner
    |> Map.get("reportingOwnerRelationship", %{})
    |> Map.get("officerTitle", "")
  end
end
