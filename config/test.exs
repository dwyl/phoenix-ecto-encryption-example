use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :encryption, EncryptionWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :encryption, Encryption.Repo,
  username: "postgres",
  password: "postgres",
  database: "encryption_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :encryption, Encryption.AES,
  key: :base64.decode("vA/K/7K6Z3obnTxlPx6fDuy/tiPj4FS7dDtUpfvRbG4=")

config :argon2_elixir,
  t_cost: 1,
  m_cost: 8
