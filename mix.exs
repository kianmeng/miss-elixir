defmodule Miss.MixProject do
  use Mix.Project

  @version "0.1.0"
  @github_url "https://github.com/prodis/miss_elixir"

  def project do
    [
      app: :miss_elixir,
      name: "Miss Elixir",
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      description: description(),
      package: package(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application, do: []

  defp deps do
    [
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21.2", only: :dev, runtime: false},
      {:excoveralls, "~> 0.11.2", only: :test}
    ]
  end

  defp description do
    """
    Some functions that we miss in Elixir core.
    """
  end

  defp dialyzer do
    [
      ignore_warnings: "dialyzer.ignore"
    ]
  end

  defp package do
    [
      maintainers: ["Fernando Hamasaki de Amorim"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @github_url}
    ]
  end

  defp docs() do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @github_url,
      canonical: "http://hexdocs.pm/miss_elixir"
    ]
  end
end
