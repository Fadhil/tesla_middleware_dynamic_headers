defmodule Tesla.Middleware.DynamicHeaders.MixProject do
  use Mix.Project

  @github "https://github.com/cogini/tesla_middleware_dyamic_headers"

  def project do
    [
      app: :tesla_middleware_dynamic_headers,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      dialyzer: [
        plt_add_apps: [:mix, :ex_unit]
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.lcov": :test,
        quality: :test,
        "quality.ci": :test
      ],
      description: description(),
      package: package(),
      # Docs
      name: "Tesla.Middleware.DynamicHeaders",
      source_url: @github,
      homepage_url: @github,
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger] ++ extra_applications(Mix.env())
    ]
  end

  defp extra_applications(:dev), do: [:tools]
  defp extra_applications(:test), do: [:tools]
  # defp extra_applications(:test), do: [:hackney]
  defp extra_applications(_), do: []

  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: [:dev, :test], runtime: false},
      {:hackney, "~> 1.18", only: [:dev, :test]},
      {:junit_formatter, "~> 3.3", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false},
      {:tesla, "~> 1.5"}
    ]
  end

  defp description do
    "Middleware for Tesla HTTP client library that sets headers dynamically at runtime"
  end

  defp package do
    [
      name: "tesla_middleware_dynamic_headers",
      maintainers: ["Jake Morrison"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @github,
        "Tesla" => "https://github.com/elixir-tesla/tesla",
        "xmlrpc" => "https://github.com/ewildgoose/elixir-xml_rpc"
      }
    ]
  end

  defp docs do
    [
      main: "Tesla.Middleware.DynamicHeaders",
      extras: [
        "README.md",
        "CHANGELOG.md": [title: "Changelog"],
        LICENSE: [title: "License (Apache 2.0)"],
        "CODE_OF_CONDUCT.md": [title: "Code of Conduct"]
      ],
      api_reference: false
      # source_url_pattern: "#{@github}/blob/master/%{path}#L%{line}"
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"],
      quality: [
        "format --check-formatted",
        "credo",
        # mix deps.clean --unlock --unused
        "deps.unlock --check-unused",
        # "hex.outdated",
        "hex.audit",
        "deps.audit",
        "dialyzer"
      ],
      "quality.ci": [
        "format --check-formatted",
        "deps.unlock --check-unused",
        # "hex.outdated",
        "hex.audit",
        "deps.audit",
        "credo",
        "dialyzer"
      ]
    ]
  end
end
