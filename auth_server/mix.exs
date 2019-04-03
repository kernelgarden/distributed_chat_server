defmodule EchoServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :auth_server,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],

      # Start EchoServer Applicaion
      mod: {AuthServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:freddie, "~> 0.1.3"},
      {:ecto_sql, "~> 3.0.5"},
      {:mariaex, "~> 0.9.1"},
      {:bcrypt_elixir, "~> 2.0"}
    ]
  end
end
