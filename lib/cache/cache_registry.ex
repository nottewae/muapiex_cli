defmodule MuapiExCli.Cache.Registry do
  use GenServer
  require Logger
  @delay 100
  def start_link(), do: GenServer.start_link(__MODULE__, nil, name: :cache_server)

  def init(_) do
    Process.send_after(self(), :update, @delay)
    {:ok, []}
  end

  def handle_info(:update, state) do
    new_state = remove_old_keys(state)
    Process.send_after(self(), :update, @delay)
    {:noreply, new_state}
  end

  def handle_call(:state, _from, state), do: {:reply, state, state}

  def handle_call({:find_key, key}, _from, state), do: {:reply, find_key(state, key), state}

  def handle_call({:key_info, key}, _from, state), do: {:reply, find_key(state, key, true), state}

  def handle_cast({:write_key,key, data, ttl},state), do: {:noreply, add_key(state, key, data, ttl)}

  defp remove_old_keys(state), do: remove_old_keys(state, [])

  defp remove_old_keys([item | items], result) do
    #Logger.debug("key: #{item |> inspect}, vaid?: #{key_valid?(item)}")
    #Logger.debug("key time: #{(:os.system_time(:millisecond) - item.time) |> inspect}, vaid?: #{key_valid?(item)}")
    result = if key_valid?(item) do
      [item | result]
    else
      result
    end
    remove_old_keys(items, result)
  end

  defp remove_old_keys([], result), do: result

  defp add_key(state, key, value, ttl), do: [%{key: key, value: value, ttl: ttl, time: :os.system_time(:millisecond)}]++ remove_key(state, key)

  defp remove_key(state, key), do: remove_key(state, key, [])

  defp remove_key([item | items], key, result) do
    result = if item.key == key do
      result
    else
      [item | result]
    end
    remove_key(items, key, result)
  end

  defp remove_key([], _key, result), do: result
  defp find_key(state, key) do
    find_key(state, key, false)
  end
  defp find_key([item | items], key, info) do
    if item.key == key and key_valid?(item) do
      if info do
        item
      else
          item.value
      end

    else
      find_key(items, key)
    end
  end

  defp find_key([], _key, _info), do: nil


  defp key_valid?(item), do:  item.ttl == :infinity or (:os.system_time(:millisecond) - item.time) <= (item.ttl * 1000)

end
