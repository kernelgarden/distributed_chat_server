# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :chat_server,
      ecto_repos: [ChatServer.Repo]

 config :chat_server,
  lookup_server_list: [
    :lookup_server_001@localhost
  ]

import_config "#{Mix.env()}.exs"
