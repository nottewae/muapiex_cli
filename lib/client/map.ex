defmodule MuapiExCli.Helpers.Map do
  def keys_to_atom(array) when is_list(array) do
    Enum.map(array, fn(item)->
      keys_to_atom(item)
    end)
  end
  def keys_to_atom(map) do
    for {key, val} <- map, into: %{}, do: {
      (if is_atom(key), do: key, else: String.to_atom(key)),
      (if is_map(val) do
        if Map.has_key?(val, :__struct__) do
          val = Map.delete(val, :__struct__)
          keys_to_atom(val)
        else
          keys_to_atom(val)
        end

      else
        val
      end)
    }
  end
  def list_to_map(list) do
    add_item_to_map(list)
  end
  defp add_item_to_map(items), do: add_item_to_map(items, %{})
  defp add_item_to_map([{key, value} | items], result) do
    add_item_to_map(items, result |> Map.put(key, value))
  end
  defp add_item_to_map([], result), do: result
  def check_fields(fields, map), do: check_fields(fields, map, true)
  def check_fields([field | fields], map, result) do
    field = if is_binary(field), do: String.to_atom(field), else: field
    result = if result do
      if Map.has_key?(map, field)  do
        result
      else
        false
      end
    else
      result
    end
    check_fields(fields, map, result)
  end
  def check_fields([], _, result), do: result
end
