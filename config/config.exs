import Config
config :muapi_ex_cli, :client_timeout, 10_000
import_config "#{Mix.env()}.exs"
