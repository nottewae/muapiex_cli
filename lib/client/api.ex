defmodule MuapiExCli.API do
  require Logger
  use HTTPoison.Base
  alias MuapiExCli.Helpers.Map, as: MapUtil
  def process_request_url(url) do
    Application.fetch_env!(:muapi_ex_cli, :host) <> url
  end

  def process_response_body(body) do
    try do
      body
      |> Poison.decode!
      |> MapUtil.keys_to_atom()
    rescue
      e in Poison.SyntaxError ->
        Logger.error("error decode answer:")
        Logger.error(inspect(e))
    end

  end

end
