defmodule Tesla.Middleware.DynamicHeaders do
  @moduledoc """
  Set headers dynamically at runtime.

  This is most useful to handle secrets that should not be compiled into the
  release.

  ## Options

  It takes a single option, either a list of tuples or a function.
  The first element of the tuple is the header name.
  Other values are as follows:

  * `{application, key}`: Reads the value from `Application.get_env/2`
  * `{application, key, default}`: Reads the value from `Application.get_env/3`
  * Function with arity 1: Calls the function with the header name to get the value
  * Any other value is passed through as is, same as `Tesla.Middleware.Headers`

  If the option is a zero-arity function, it is called to generate a list of
  `{header_name, value`} tuples.

  ## Examples

  ```
  defmodule FooClient do
    use Tesla

    plug Tesla.Middleware.DynamicHeaders, [
      {"X-Foo-Token", {:my_client, :foo_token}},
      {"X-Bar-Token", {:my_client, :bar_token, "default"}},
      {"Authorization", &get_authorization/1}},
      {"content/type", "application/json"}
    ]

    defp get_authorization(header_name) do
      {header_name, "token: " <> Application.get_env(:my_client, :auth_token)}
    end
  end
  ```

  ```
  defmodule FooClient do
    use Tesla

    plug Tesla.Middleware.DynamicHeaders, &get_dynamic_headers/0

    defp get_dynamic_headers do
      Application.get_env(:foo_client, :auth_headers)
    end
  end
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
