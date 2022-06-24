defmodule Encryption.Mixfile do
  use Mix.Project

  def project do
    [
      app: :encryption,
      version: "1.0.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        c: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Encryption.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [ # Default Phoenix Dependencies
      {:phoenix, "~> 1.6.10"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:gettext, "~> 0.11"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.8.3"},
      {:postgrex, ">= 0.15.13"},

      {:argon2_elixir, "~> 1.3"},  # securely hashing & verifying passwords
      # Development dependencies:

      # Check test coverage: hex.pm/packages/excoveralls
      {:excoveralls, "~> 0.14.5", only: :test},
      {:dogma, "~> 0.1", only: [:test, :dev]}, # Elixir style
      {:credo, "~> 1.6.4", only: [:dev, :test]}, # github.com/rrrene/credo
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      c: ["coveralls.html"],
      cover: ["coveralls.json"],
      "cover.html": ["coveralls.html"]
    ]
  end
end
