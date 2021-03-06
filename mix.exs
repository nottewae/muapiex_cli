defmodule MuapiExCli.MixProject do
  use Mix.Project
  # import Config

  def project do
    [
      app: :muapi_ex_cli,
      version: "0.1.5",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :dev,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do

    [
      extra_applications: [:logger, :httpoison],
      mod: {MuapiExCli.Application, []}
      # env: config_env()

    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:poison, "~> 3.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
