defmodule InsiderTradingWeb.Api.TradeInfoControllerTest do
  use InsiderTradingWeb.ConnCase

  test "GET /api/v1/inside_trade/:ticker", %{conn: conn} do
    conn = get(conn, ~p"/api/v1/inside_trade/app")
    assert json_response(conn, 200)["data"] == nil
  end
end
