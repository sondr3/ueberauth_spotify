defmodule UeberauthSpotify.MixProject do
  use Mix.Project

  @source_url "https://github.com/sondr3/ueberauth_spotify"
  @version "0.1.0"

  def project do
    [
      app: :ueberauth_spotify,
      version: @version,
      elixir: "~> 1.15",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ueberauth, :oauth2]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oauth2, "~> 2.1"},
      {:ueberauth, "~> 0.10"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "README.md": [title: "Overview"],
        "CHANGELOG.md": [title: "Changelog"],
        "CONTRIBUTING.md": [title: "Contributing"],
        LICENSE: [title: "License"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "#v{@version}",
      formatters: ["html"]
    ]
  end

  defp package do
    [
      description: "An Ueberauth strategy for using Spotify to authenticate your users.",
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Sondre Aasemoen"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://hexdocs.pm/ueberauth_spotify/changelog.html",
        GitHub: @source_url
      }
    ]
  end
end
