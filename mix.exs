defmodule Speakeasy.MixProject do
  use Mix.Project

  def project do
    [
      app: :speakeasy,
      version: "0.1.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Speakeasy",
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
      {:bodyguard, "~> 2.2"},
      {:absinthe, "~> 1.4"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
