defmodule Tesla.Middleware.DynamicHeaders.ClientTest do
  use ExUnit.Case

  import Tesla.Mock

  setup do
    mock(fn env -> %Tesla.Env{status: 200, body: "ok!", headers: env.headers} end)
    :ok
  end

  test "test client" do
    {:ok, result} = Tesla.Middleware.DynamicHeaders.Test.Client.test("/hello")

    assert [
      {"X-Foo-Token", "footoken"},
      {"X-Bar-Token", "bartoken"},
      {"Authorization", "token: authtoken"},
      {"content/type", "application/json"}
    ] = result.headers
  end

  test "all headers by fun" do
    {:ok, result} = Tesla.Middleware.DynamicHeaders.Test.HeadersClient.test("/hello")

    assert [
      {"Authorization", "token: authtoken"},
    ] = result.headers
  end
end
