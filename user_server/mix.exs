defmodule UserServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :user_server,
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
      mod: {UserServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:freddie, "~> 0.1.5"}
    ]
  end
end
