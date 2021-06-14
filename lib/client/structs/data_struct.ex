defmodule MuapiExCli.Client.Data do
  defstruct [:time]
  @derive [Poison.Encoder]
  def new() do
    %MuapiExCli.Client.Data{time: :os.system_time(:second)}
  end
  def make_sign(data = %MuapiExCli.Client.Data{}, private_key) do
    str_data = Poison.encode!(data)
    sign = :crypto.hash(:sha256, "#{str_data}#{private_key}")
    |> Base.encode16()
    |> String.downcase()
    {sign, str_data}
  end
end
