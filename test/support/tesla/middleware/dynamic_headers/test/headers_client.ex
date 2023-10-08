defmodule Tesla.Middleware.DynamicHeaders.Test.HeadersClient do
  @moduledoc false

  use Tesla

  @app :tesla_middleware_dynamic_headers

  plug(Tesla.Middleware.BaseUrl, "https://example.com/")
  plug Tesla.Middleware.DynamicHeaders, &get_dynamic_headers/0
  plug(Tesla.Middleware.Logger)

  def test(path) do
    get(path)
  end

  defp get_dynamic_headers do
    Application.get_env(@app, :headers)
  end
end
