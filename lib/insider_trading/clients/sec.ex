defmodule InsiderTrading.Clients.Sec do
  import SweetXml

  alias InsiderTrading.Clients.Helpers
  alias InsiderTrading.Core.InsiderTrade
  alias InsiderTrading.Core.TraderInfo
  alias InsiderTrading.Core.Transaction

  @request_headers [{"User-Agent", "trading/0.1.0"}, {"Accept", "*/*"}]
  @base_url "https://www.sec.gov"

  def get_tickers_exchange() do
    with {:ok, response} <- Helpers.get(@request_headers, tickers_exchange_endpoint()) do
      Jason.decode(response)
    end
  end

  def get_trade_by_cik(cik) do
    with {:ok, response} <- Helpers.get(@request_headers, ticker_info_endpoint(cik)) do
      {:ok, parse_xml(response)}
    end
  end

  def get_company_forms(endpoint, marketcap) do
    with {:ok, response} <- Helpers.get(@request_headers, endpoint),
         {:ok, endpoint} <- extract_form_data(response),
         company_data <- get_company_form_data(endpoint, marketcap) do
      company_data
    end
  end

  def get_company_form_data(endpoint, marketcap) do
    endpoint = "#{@base_url}/#{endpoint}"

    with {:ok, response} <- Helpers.get(@request_headers, endpoint),
         form_data <- XmlToMap.naive_map(response),
         ownership_document <- Map.get(form_data, "ownershipDocument", %{}),
         trader_info <- TraderInfo.parse(ownership_document),
         transaction_info <- Transaction.parse(ownership_document, marketcap) do
      InsiderTrade.new(transaction_info, trader_info)
    end
  end

  defp extract_form_data(response) do
    case Floki.parse_document(response) do
      {:ok, parsed_page} ->
        url =
          parsed_page
          |> Floki.find("a")
          |> Enum.filter(&(Floki.text(&1) =~ ~r/.xml/))
          |> Enum.find_value(&Floki.attribute(&1, "href"))
          |> List.first()

        {:ok, url}

      response ->
        response
    end
  end

  defp parse_xml(response) do
    response
    |> SweetXml.parse(namespace_conformant: true)
    |> xpath(~x"//entry/content"l,
      form_type: ~x"./filing-type/text()"s,
      form_href: ~x"./filing-href/text()"s
    )
    |> Enum.filter(&(&1.form_type == "4"))
    |> Enum.map(& &1.form_href)
  end

  defp tickers_exchange_endpoint(), do: "#{@base_url}/files/company_tickers_exchange.json"

  defp ticker_info_endpoint(cik),
    do:
      "#{@base_url}/cgi-bin/browse-edgar?action=getcompany&CIK=#{cik}&owner=include&count=100&output=atom"
end
