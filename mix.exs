defmodule Speakeasy.MixProject do
  use Mix.Project

  def project do
    [
      app: :speakeasy,
      version: "0.3.1",
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Speakeasy",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.html": :test, "coveralls.travis": :test],
      docs: [
        extras: ["README.md"],
        main: "readme"
      ]
    ]
  end

  defp description do
    """
    Middleware based authentication and authorization for Absinthe GraphQL powered by Bodyguard
    """
  end

  defp package do
    [
      name: :speakeasy,
      maintainers: ["Cory O'Daniel"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/coryodaniel/speakeasy"
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4", optional: true},
      {:bodyguard, "~> 2.2"},
      {:ex_doc, "~> 0.18", only: [:dev, :docs], runtime: false},
      # {:ex_doc, "~> 0.19.1", only: [:dev, :docs], runtime: false},
      # {:inch_ex, github: "rrrene/inch_ex", only: [:dev, :test, :docs]},
      {:excoveralls, "~> 0.8", only: [:test]}
    ]
  end
end
