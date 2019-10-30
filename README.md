# GenQueue Oban
[![Build Status](https://travis-ci.org/Trax-retail/gen_queue_oban.svg?branch=master)](https://travis-ci.org/Trax-retail/gen_queue_oban)
[![GenQueue Oban Version](https://img.shields.io/hexpm/v/gen_queue_oban.svg)](https://hex.pm/packages/gen_queue_oban)

This is an adapter for [GenQueue](https://github.com/nsweeting/gen_queue) to enable
functionality with [Oban](https://github.com/sorentwo/oban).

## Installation

The package can be installed by adding `gen_queue_oban` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gen_queue_oban, "~> 0.1.0"}
  ]
end
```

## Documentation

See [HexDocs](https://hexdocs.pm/gen_queue_oban) for additional documentation.

## Configuration

Before starting, please refer to the [Oban](https://github.com/sorentwo/oban) documentation
for details on configuration. This adapter handles zero `Oban` related config.

## Creating Enqueuers

We can start off by creating a new `GenQueue` module, which we will use to push jobs to
`Oban`.

```elixir
defmodule Enqueuer do
  use GenQueue, otp_app: :my_app
end
```

Once we have our module setup, ensure we have our config pointing to the `GenQueue.Adapters.Oban`
adapter.

```elixir
config :my_app, Enqueuer, [
  adapter: GenQueue.Adapters.Oban
]
```

## Starting Enqueuers

By default, `gen_queue_oban` does not start Oban on application start. So we must add
our new `Enqueuer` module to our supervision tree.

```elixir
  children = [
    supervisor(Enqueuer, []),
  ]
```

## Creating Jobs

Jobs are simply modules with a `perform` method. With `Oban` we must add `use Oban.Worker`
to our jobs with the relevant configuration.

```elixir
defmodule MyJob do
  use Oban.Worker, queue: "events", max_attempts: 10

  @impl Oban.Worker
  def perform(arg1, _job) do
    IO.inspect(arg1)
  end
end
```

## Enqueuing Jobs

We can now easily enqueue jobs to `Oban`. The adapter will handle a variety of argument formats.

```elixir
# Please note that zero-arg jobs default to using %{}, as per Oban requirements.

# Push MyJob to your default queue with %{} arg.
{:ok, job} = Enqueuer.push(MyJob)

# Push MyJob to your default queue  with %{} arg.
{:ok, job} = Enqueuer.push({MyJob})

# Push MyJob to your default queue with %{"foo" => "bar"} arg.
{:ok, job} = Enqueuer.push({MyJob, %{"foo" => "bar"}})

# Push MyJob to "default" queue with %{} arg.
{:ok, job} = Enqueuer.push({MyJob, []})

# Push MyJob to "default" queue with %{"foo" => "bar"} arg.
{:ok, job} = Enqueuer.push({MyJob, [%{"foo" => "bar"}]})

# Push MyJob to "foo" queue with %{"foo" => "bar"} arg
{:ok, job} = Enqueuer.push({MyJob, %{"foo" => "bar"}}, [queue: "foo"])

# Schedule MyJob to your default queue with %{"foo" => "bar"} arg in 10 seconds
{:ok, job} = Enqueuer.push({MyJob, %{"foo" => "bar"}}, [delay: 10_000])

# Schedule MyJob to your default queue with %{"foo" => "bar"} arg at a specific time
date = DateTime.utc_now()
{:ok, job} = Enqueuer.push({MyJob, %{"foo" => "bar"}}, [delay: date])
```

## Testing

Optionally, we can also have our tests use the `GenQueue.Adapters.MockJob` adapter.

```elixir
config :my_app, Enqueuer, [
  adapter: GenQueue.Adapters.MockJob
]
```

This mock adapter uses the standard `GenQueue.Test` helpers to send the job payload
back to the current processes mailbox (or another named process) instead of actually
enqueuing the job to rabbitmq.

```elixir
defmodule MyJobTest do
  use ExUnit.Case, async: true

  import GenQueue.Test

  setup do
    setup_test_queue(Enqueuer)
  end

  test "my enqueuer works" do
    {:ok, _} = Enqueuer.push(Job)
    assert_receive(%GenQueue.Job{module: Job, args: []})
  end
end
```

If your jobs are being enqueued outside of the current process, we can use named
processes to recieve the job. This wont be async safe.

```elixir
import GenQueue.Test

setup do
  setup_global_test_queue(Enqueuer, :my_process_name)
end
```
