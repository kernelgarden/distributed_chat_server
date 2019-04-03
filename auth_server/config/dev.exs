use Mix.Config

config :auth_server, AuthServer.Repo,
  database: "auth_server_dev_repo",
  username: "root",
  password: "tabstorage",
  hostname: "localhost"
