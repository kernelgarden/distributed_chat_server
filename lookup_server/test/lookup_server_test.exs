defmodule LookupServerTest do
  use ExUnit.Case
  doctest LookupServer

  test "greets the world" do
    assert LookupServer.hello() == :world
  end
end
