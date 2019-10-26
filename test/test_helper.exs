defmodule GenQueue.ObanTestHelpers do
  def stop_process(pid) do
    try do
      Process.flag(:trap_exit, true)
      Process.exit(pid, :shutdown)

      receive do
        {:EXIT, _pid, _error} -> :ok
      end
    rescue
      e in RuntimeError -> e
    end

    Process.flag(:trap_exit, false)
  end
end

{:ok, _pid} = GenQueue.Repo.start_link
Ecto.Adapters.SQL.Sandbox.mode(GenQueue.Repo, :manual)

ExUnit.start()

