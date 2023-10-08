defmodule Tesla.Middleware.DynamicHeadersTest do
  use ExUnit.Case
  doctest Tesla.Middleware.DynamicHeaders

  test "greets the world" do
    assert Tesla.Middleware.DynamicHeaders.hello() == :world
  end
end
