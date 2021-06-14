defmodule MuapiExCli.Application do
  use Application
  import Config
  def start(_type, _args) do
    import Supervisor.Spec
    children = [
      %{
        id: :cli_cache,
        start: {MuapiExCli.Cache, :start_link, [[]]}
      }
    ]
    opts = [strategy: :one_for_one, name: MuapiExCli.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
