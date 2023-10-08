defmodule Tesla.Middleware.DynamicHeaders.BasicTest do
  use ExUnit.Case

  alias Tesla.Middleware.DynamicHeaders

  @app :tesla_middleware_dynamic_headers

  defp get_authorization("Authorization") do
    Application.get_env(@app, :auth_token)
  end

  describe "get_header/2 Application.get_env/2" do
    test "returns value" do
      assert {"Foo", "footoken"} = DynamicHeaders.get_header({"Foo", {@app, :foo_token}})
    end

    test "returns nil if missing" do
      assert {"Foo", nil} = DynamicHeaders.get_header({"Foo", {@app, :missing}})
    end
  end

  describe "get_header/2 Application.get_env/3" do
    test "returns value" do
      assert {"Bar", "bartoken"} = DynamicHeaders.get_header({"Bar", {@app, :bar_token, "default"}})
    end

    test "returns default value if missing" do
      assert {"Bar", "default"} = DynamicHeaders.get_header({"Bar", {@app, :missing, "default"}})
    end
  end

  describe "get_header/2 fun" do
    test "calls function" do
      assert {"Authorization", "authtoken"} = DynamicHeaders.get_header({"Authorization", &get_authorization/1})
    end
  end

  describe "get_header/2 static value" do
    test "returns staticvalue" do
      assert {"Static", "staticvalue"} = DynamicHeaders.get_header({"Static", "staticvalue"})
    end
  end
end
