defmodule GenQueue.Adapters.Oban do
  @moduledoc """
  An adapter for `GenQueue` to enable functionality with `Oban`.
  """

  use GenQueue.JobAdapter

  def start_link(_gen_queue, _opts) do
    Oban.start_link(Application.get_env(:gen_queue_oban, Oban))
  end

  @doc """
  Push a `GenQueue.Job` for `Oban` to consume.

  ## Parameters:
    * `gen_queue` - A `GenQueue` module
    * `job` - A `GenQueue.Job`

  ## Returns:
    * `{:ok, job}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @spec handle_job(gen_queue :: GenQueue.t(), job :: GenQueue.Job.t()) ::
          {:ok, GenQueue.Job.t()} | {:error, any}
  def handle_job(gen_queue, %GenQueue.Job{args: []} = job) do
    handle_job(gen_queue, %{job | args: [%{}]})
  end

  def handle_job(_gen_queue, %GenQueue.Job{args: [arg]} = job) do
    case arg |> job.module.new(build_options(job)) |> Oban.insert() do
      {:ok, _} -> {:ok, job}
      error -> error
    end
  end

  defp build_options(%GenQueue.Job{delay: %DateTime{} = delay}) do
    s_delay = DateTime.diff(delay, DateTime.utc_now(), :second)
    [schedule_in: s_delay]
  end

  defp build_options(%GenQueue.Job{delay: delay}) when is_integer(delay) do
    s_delay = round(delay/1_000)
    [schedule_in: s_delay]
  end

  defp build_options(%GenQueue.Job{}) do
    []
  end
end
