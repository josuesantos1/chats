defmodule Backend.MixProject do
  use Mix.Project

  def project do
    [
      app: :backend,
      version: "0.1.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      listeners: [Phoenix.CodeReloader],
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        plt_add_apps: [:mix, :ex_unit],
        flags: [:error_handling, :underspecs]
      ]
    ]
  end

  def application do
    [
      mod: {Backend.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [
        quality: :dev,
        security: :dev,
        ci: :test,
        precommit: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.cobertura": :test,
        credo: :dev,
        dialyzer: :dev,
        sobelow: :dev
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Phoenix
      {:phoenix, "~> 1.8.9"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      {:cors_plug, "~> 3.0"},
      {:bcrypt_elixir, "~> 3.0"},

      # Quality
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.23", only: :dev, runtime: false},

      # Security
      {:sobelow, "~> 0.14", only: [:dev, :test], runtime: false, warn_if_outdated: true},

      # Tests
      {:stream_data, "~> 1.3", only: :test},
      {:mox, "~> 1.2", only: :test},
      {:bypass, "~> 2.1", only: :test},
      {:excoveralls, "~> 0.18", only: :test, runtime: false},

      # Documentation
      {:ex_doc, "~> 0.38", only: :dev, runtime: false},

      # Benchmarks
      {:benchee, "~> 1.3", only: :dev}
    ]
  end

  defp aliases do
    [
      setup: [
        "deps.get",
        "ecto.setup"
      ],
      "ecto.setup": [
        "ecto.create",
        "ecto.migrate",
        "run priv/repo/seeds.exs"
      ],
      "ecto.reset": [
        "ecto.drop",
        "ecto.setup"
      ],
      test: [
        "ecto.create --quiet",
        "ecto.migrate --quiet",
        fn _ ->
          src = "_build/test/lib/bcrypt_elixir/priv/bcrypt_nif.so"
          dst = "_build/test/lib/bcrypt_elixir/priv/bcrypt_nif.dll"
          if File.exists?(src) and not File.exists?(dst), do: File.cp!(src, dst)
        end,
        "test"
      ],
      quality: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "credo --strict"
      ],
      security: [
        "sobelow"
      ],
      ci: [
        "quality",
        "dialyzer",
        "security",
        "test",
        "coveralls"
      ],
      precommit: [
        "ci"
      ]
    ]
  end
end
