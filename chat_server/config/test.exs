use Mix.Config

config :chat_server, ChatServer.Repo,
  database: "chat_server_test_repo",
  username: "root",
  password: "tabstorage",
  hostname: "localhost"
