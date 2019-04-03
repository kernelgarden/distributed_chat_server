use Mix.Config

config :auth_server, AuthServer.Repo,
  database: "auth_server_test_repo",
  username: "root",
  password: "tabstorage",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
