defmodule Tesla.Middleware.DynamicHeaders do
  @moduledoc """
  Middleware for the [Tesla](https://hexdocs.pm/tesla/readme.html) HTTP client
  that sets value for HTTP headers dynamically at runtime from the application
  environment.

  This is most useful to handle secrets such as auth tokens. If you set secrets at
  compile time, then they are hard coded into the release file, a security risk.
  Similarly, if you build your code in a CI system, then you have to make the
  secrets available there.

  ## Options

  The plug takes a single argument, either a list of tuples or a function.
  The first element of the tuple is the header name. Other values are as follows:

  * `{application, key}`: Read the value from `Application.get_env/2`
  * `{application, key, default}`: Read the value from `Application.get_env/3`
  * Function with arity 1: Call the function with the header name to get the value
  * Any other value is passed through as is, same as `Tesla.Middleware.Headers`

  If the argument is a zero-arity function, it is called to generate a list of
  `{header_name, value}` tuples.

  ## Examples

  ```
  defmodule FooClient do
    use Tesla

    @app :foo_client

    plug Tesla.Middleware.BaseUrl, "https://example.com/"

    plug Tesla.Middleware.DynamicHeaders, [
      {"X-Foo-Token", {@app, :foo_token}},
      {"X-Bar-Token", {@app, :bar_token, "default"}},
      {"Authorization", &get_authorization/1},
      {"content/type", "application/json"}
      ]

    plug Tesla.Middleware.Logger

    defp get_authorization(header_name) do
      {header_name, "token: " <> Application.get_env(@app, :auth_token)}
    end
  end
  ```

  The following example uses a custom function to generate all the headers:

  ```
  defmodule FooClient do
    use Tesla

    @app :foo_client

    plug Tesla.Middleware.DynamicHeaders, &get_dynamic_headers/0

    defp get_dynamic_headers do
      Application.get_env(@app, :headers)
    end
  end
  ```

  The app configuration in `config/test.exs` might look like:

  ```
  config :foo_client,
    foo_token: "footoken",
    bar_token: "bartoken",
    auth_token: "authtoken"

  config :foo_client,
    headers: [
      {"Authorization", "token: authtoken"}
    ]
  ```

  In production, you would normally set environment variables with the tokens
  then read them in `config/runtime.exs`:

  ```
  config :foo_client,
    foo_token: System.get_env("FOO_TOKEN") || raise "missing environment variable FOO_TOKEN"
  ```

  """
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, fun) when is_function(fun) do
    env
    |> Tesla.put_headers(fun.())
    |> Tesla.run(next)
  end

  def call(env, next, headers) do
    env
    |> Tesla.put_headers(Enum.map(headers, &get_header/1))
    |> Tesla.run(next)
  end

  def get_header({header_name, {app, key, default}}) do
    {header_name, Application.get_env(app, key, default)}
  end

  def get_header({header_name, {app, key}}) do
    {header_name, Application.get_env(app, key)}
  end

  def get_header({header_name, fun}) when is_function(fun, 1) do
    {header_name, fun.(header_name)}
  end

  def get_header({header_name, value}) do
    {header_name, value}
  end
end
