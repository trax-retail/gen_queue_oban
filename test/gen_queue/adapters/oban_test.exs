defmodule GenQueue.Adapters.ObanTest do
  use ExUnit.Case, async: true

  import GenQueue.ObanTestHelpers

  alias GenQueue.Repo

  use Oban.Testing, repo: Repo

  defmodule Enqueuer do
    Application.put_env(:gen_queue_oban, __MODULE__, adapter: GenQueue.Adapters.Oban)

    use GenQueue, otp_app: :gen_queue_oban
  end

  defmodule Job do
    use Oban.Worker, queue: "events", max_attempts: 1

    @impl Oban.Worker
    def perform(_arg1, _job), do: :ok
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "push/2" do
    test "enqueues and runs job from module" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push(Job)
      assert_enqueued(worker: Job, args: %{})
      assert %GenQueue.Job{module: Job, args: [%{}]} = job
      stop_process(pid)
    end

    test "enqueues and runs job from module tuple" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push({Job})
      assert_enqueued(worker: Job, args: %{})
      assert %GenQueue.Job{module: Job, args: [%{}]} = job
      stop_process(pid)
    end

    test "enqueues and runs job from module and args" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push({Job, [%{"foo" => "bar"}]})
      assert_enqueued(worker: Job, args: %{"foo" => "bar"})
      assert %GenQueue.Job{module: Job, args: [%{"foo" => "bar"}]} = job
      stop_process(pid)
    end

    test "enqueues and runs job from module and single arg" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push({Job, %{"foo" => "bar"}})
      assert_enqueued(worker: Job, args: %{"foo" => "bar"})
      assert %GenQueue.Job{module: Job, args: [%{"foo" => "bar"}]} = job
      stop_process(pid)
    end

    test "enqueues a job with millisecond based delay" do
      delay_ms = 1_000
      dt_delay = DateTime.add(DateTime.utc_now(), delay_ms, :millisecond)
      dt_delay_with_delta = DateTime.add(dt_delay, 60, :second)
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push({Job, []}, delay: delay_ms)
      assert_enqueued(worker: Job, args: %{})
      [record] = all_enqueued(worker: Job, args: %{})
      assert [:gt, :eq] |> Enum.member?(DateTime.compare(record.scheduled_at, dt_delay))
      assert DateTime.compare(record.scheduled_at, dt_delay_with_delta) == :lt
      assert %GenQueue.Job{module: Job, args: [%{}], delay: delay_ms} = job
      stop_process(pid)
    end

    test "enqueues a job with datetime based delay" do
      dt_delay = DateTime.add(DateTime.utc_now(), 3600, :second)
      dt_delay_with_delta = DateTime.add(dt_delay, 60, :second)
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push({Job, []}, delay: dt_delay)
      assert_enqueued(worker: Job, args: %{})
      [record] = all_enqueued(worker: Job, args: %{})
      assert [:gt, :eq] |> Enum.member?(DateTime.compare(record.scheduled_at, dt_delay))
      assert DateTime.compare(record.scheduled_at, dt_delay_with_delta) == :lt
      assert %GenQueue.Job{module: Job, args: [%{}], delay: %DateTime{}} = job
      stop_process(pid)
    end
  end
end
