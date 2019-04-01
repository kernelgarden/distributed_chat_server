# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# To configure freddie
config :freddie,
  # Type app name
  app_mod: :auth_server,
  # Type listen port
  port: 5050,
  # Type acceptor pool size
  acceptor_pool_size: 16,
  # Type redis host address
  redis_host: "localhost",
  # Type redis port
  redis_port: 6379,
  # Type redis pool size
  redis_pool_size: 10,
  # Type srotocol scheme root mod
  scheme_root_mod: AuthServer.Scheme,
  # Type protocol type root mod
  packet_type_mod: AuthServer.Protocol.Types,
  # Type packet handler mod (derive from Freddie.Router)
  packet_handler_mod: AuthServer.Handler
