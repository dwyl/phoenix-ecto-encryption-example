# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config
System.cmd("whoami", [])
# General application configuration
config :encryption,
  ecto_repos: [Encryption.Repo]

# Configures the endpoint
config :encryption, EncryptionWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3PXN/6k6qoxqQjWFskGew4r74yp7oJ1UNF6wjvJSHjC5Y5LLIrDpWxrJ84UBphJn",
  render_errors: [view: EncryptionWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Encryption.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# run shell command to "source .env" to load the environment variables.
:os.cmd('source .env')
:os.cmd(:"source .env")
System.cwd() |> IO.inspect(label: "cwd")
# System.cmd("source", [".env"])
# :os.cmd("source .env")
"source .env" |> String.to_charlist |> :os.cmd |> IO.inspect

# Map.fetch!(System.get_env(), "HELLO") |> IO.inspect

File.stream!("./.env")
  |> Stream.map(&String.trim_trailing/1) # remove excess whitespace
  |> Enum.each(fn line -> line           # loop through each line
    |> String.replace("export ", "")     # remove "export" from line
    |> String.split("=")                 # split on the "=" (equals sign)
    |> Enum.reduce(fn(value, key) ->
      System.put_env(key, value)         # set each environment variable
    end)
  end)

System.get_env() |> IO.inspect
