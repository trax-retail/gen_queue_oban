use Mix.Config

# Repos known to Ecto:
config :gen_queue_oban, ecto_repos: [GenQueue.Repo]

# Test Repo settings
config :gen_queue_oban, GenQueue.Repo,
  username: "postgres",
  password: "postgres",
  database: "gen_queue_oban_test",
  hostname: "localhost",
  priv: "test/support/repo",
  pool: Ecto.Adapters.SQL.Sandbox

config :gen_queue_oban, Oban,
  repo: GenQueue.Repo,
  queues: false,
  prune: :disabled
