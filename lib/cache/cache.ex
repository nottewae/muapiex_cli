defmodule MuapiExCli.Cache do
  require Logger
  def start_link(_), do: MuapiExCli.Cache.Registry.start_link

  def child_spec(opts), do:
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }

  def all, do: :cache_server |> GenServer.call(:state)

  def info(key, user_id \\ nil, options \\ []), do: :cache_server |> GenServer.call({:key_info, prefix(user_id, options) <> key})

  @spec read(binary, any, [{any, any}]) :: any
  def read(key, user_id \\ nil, options \\ []), do: :cache_server |> GenServer.call({:find_key, prefix(user_id, options) <> key})

  def write(key, data, ttl \\ :infinity, user_id \\ nil, options \\ []) when is_binary(key) and not is_nil(data), do:
    :cache_server |> GenServer.cast({:write_key, prefix(user_id, options) <> key, data, ttl})

  def delete(key, user_id \\ nil, options \\ []) when is_binary(key), do:
    :cache_server |> GenServer.cast({:write_key, prefix(user_id, options) <> key, nil, 0})

  defmacro fetch(key, ttl \\ :infinity, user_id \\ nil, options \\ [], do: block) do
    quote do
      require Logger
      ttl = if unquote(ttl) <1, do: 1, else: unquote(ttl)
      alias MuapiExCli.Cache
      case Cache.read(unquote(key), unquote(user_id), unquote(options)) do
        nil->
          Cache.write(unquote(key), unquote(block), unquote(ttl), unquote(user_id), unquote(options))
          Cache.read(unquote(key), unquote(user_id), unquote(options))
        data->
          #Logger.debug "cache"
          data
      end
    end
  end

  defp prefix(user_id, options) do
    trivial = if user_id, do: "user::#{user_id}::", else: ""
    join_options(options, trivial)

  end

  defp join_options([option | options], res) do
    {key, value} = option
    unless key == :ttl do
      join_options(options, "#{res}_#{key}::#{value}")
    else
      join_options(options, res)
    end
  end
  defp join_options([], res), do: res

end
