defmodule GenQueueTaskBunny.MixProject do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      app: :gen_queue_task_bunny,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "GenQueue TaskBunny",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    GenQueue adapter for TaskBunny
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Nicholas Sweeting"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/nsweeting/gen_queue_task_bunny",
        "GenQueue" => "https://github.com/nsweeting/gen_queue"
      }
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_url: "https://github.com/nsweeting/gen_queue_task_bunny"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_queue, "~> 0.1.5"},
      {:task_bunny, "~> 0.3.1", runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
