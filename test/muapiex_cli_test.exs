defmodule MuapiexCliTest do
  use ExUnit.Case
  doctest MuapiexCli

  test "greets the world" do
    assert MuapiexCli.hello() == :world
  end
end
