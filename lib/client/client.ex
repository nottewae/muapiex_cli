defmodule MuapiExCli.Client do
  require Logger
  require MuapiExCli.Cache
  def auth() do
    data = MuapiExCli.Client.Data.new
    post("/auth", data, "elixir_client_auth", nil)
  end
  # def insert_resource(request, meta \\ "elixir_client", opt\\[]) do
  #   # # fetch_resource(:item, "/resource/add", %{}, request, meta, opt)
  #   # # ensure_started()
  #   # data = MuapiExCli.Client.Data.new
  #   # {sign, data} = MuapiExCli.Client.Data.make_sign(data, config()[:private_key])
  #   # data = %{sign: sign, public_key: config()[:public_key], data: request, meta: meta}
  #   # # data = Map.merge(data, request)
  #   # # # Poison.encode!(data)
  #   # MuapiExCli.API.post("/resource/add", Poison.encode!(data),[{"Content-Type", "application/json"}], opt)



  #   # # fetch_resource(:item, "/resource/add", %{}, request, meta, opt)
  #   # data = MuapiExCli.Client.Data.new
  #   # data = Map.merge(data, %{data: request})
  #   # post("/resource/add", request, "elixir_client")
  #   # post(uri, data, meta, resource, opt\\[])
  # end
  def insert_category(request, meta \\ "elixir_client", opt\\[]) do
    fetch_resource(:catalog, "/resource/catalog/add", %{}, request, meta, opt)
  end
  def insert_item(request, meta \\ "elixir_client", opt\\[]) do
    fetch_resource(:item, "/resource/catalog/item/add", %{}, request, meta, opt)
  end
  def get_resources(meta \\ "elixir_client", ttl \\ 1, opt\\[]) do
    MuapiExCli.Cache.fetch("get_resource_#{get_resource()}", ttl,opt) do
      data = MuapiExCli.Client.Data.new
      post("/resources", data, meta,nil,opt)
    end
  end
  def get_category(request, paginator \\ %{page: 1, per_page: 100}, meta \\ "elixir_client", ttl \\ 1, opt\\[]) do
    MuapiExCli.Cache.fetch("#{Poison.encode!(request)}_#{Poison.encode!(paginator)}_#{get_resource()}", ttl,nil, opt) do
      fetch_resource(:catalog, "/resource/catalog", paginator, request, meta, opt)
    end

  end
  def get_items(request, paginator \\ %{page: 1, per_page: 100}, meta \\ "elixir_client", ttl \\ 1, opt\\[]) do
    MuapiExCli.Cache.fetch("#{Poison.encode!(request)}_#{Poison.encode!(paginator)}_#{get_resource()}", ttl,nil, opt) do
      fetch_resource(:item, "/resource/catalog/item", paginator, request, meta, opt)
    end
  end

  def set_resource(resource_name) do
    make_table()
    :ets.insert(:client, {"resource", resource_name})
  end
  defp make_paginator(paginator) when is_map(paginator) do
    paginator = if Map.has_key?(paginator, :page) do
      paginator
    else
      Map.merge(paginator, %{page: 1})
    end
    if Map.has_key?(paginator, :per_page) do
      paginator
    else
      Map.merge(paginator, %{per_page: 100})
    end
  end

  defp get_resource() do
    case  :ets.lookup(:client, "resource") do
      [{_, value}] -> value
      _-> raise("first you must set resource, set_resource(\"resource_name\")")
    end
  end
  defp make_table() do
    try do
      :ets.new(:client, [:set, :protected, :named_table])
    rescue e->
      Logger.warn("table already exists")
      :client
    end
  end
  defp ensure_started do
    MuapiExCli.API.start
  end
  defp fetch_resource(key, path, paginator, request, meta, opt\\[]) do
    data = MuapiExCli.Client.Data.new
    # IO.inspect data
    data = Map.merge(data, %{key => request})
    # IO.inspect data
    paginator = make_paginator(paginator)
    data = Map.merge(data, %{paginator: paginator})
    # IO.inspect data
    post(path, data, meta, get_resource(),opt)
  end
  defp post(uri, data, meta, resource, opt\\[]) do
    # IO.inspect data
    ensure_started()
    data = if is_nil(resource) do
      data
    else
      Map.merge(data, %{resource: resource})
    end
    # IO.inspect data
    {sign, data} = MuapiExCli.Client.Data.make_sign(data, config()[:private_key])
    data = Poison.decode!(data)
    # IO.inspect data
    data = %{sign: sign, public_key: config()[:public_key], data: data, meta: meta}
    # data |> IO.inspect
    # IO.inspect Poison.encode!(data)
    data = MuapiExCli.Helpers.Map.keys_to_atom(data)
    data |> IO.inspect
    MuapiExCli.API.post(uri, Poison.encode!(data),[], opt)
    # MuapiExCli.API.post(uri, Poison.encode!(data),[{"Content-Type", "application/json"}], opt)
  end


  def config do
    [
      public_key: Application.fetch_env!(:muapi_ex_cli, :public_key),
      private_key: Application.fetch_env!(:muapi_ex_cli, :private_key),
      host: Application.fetch_env!(:muapi_ex_cli, :host),
      timeout: Application.fetch_env!(:muapi_ex_cli, :client_timeout)
    ]
  end
end
