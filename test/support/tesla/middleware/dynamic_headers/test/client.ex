defmodule Tesla.Middleware.DynamicHeaders.Test.Client do
  @moduledoc false

  use Tesla

  @app :tesla_middleware_dynamic_headers

  plug(Tesla.Middleware.BaseUrl, "https://example.com/")
  plug Tesla.Middleware.DynamicHeaders, [
    {"X-Foo-Token", {@app, :foo_token}},
    {"X-Bar-Token", {@app, :bar_token, "default"}},
    {"Authorization", &get_authorization/1},
    {"content/type", "application/json"}
  ]
  plug(Tesla.Middleware.Logger)

  def test(path) do
    get(path)
  end

  defp get_authorization("Authorization") do
    "token: " <> Application.get_env(@app, :auth_token)
  end
end
