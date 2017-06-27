defmodule BusBar.SupervisorTest do
  use ExUnit.Case
  doctest BusBar.Supervisor

  alias BusBar.Supervisor

  test "children returns the children of this supervisor only" do
    assert Supervisor.children == []
  end

  defmodule TestWorker do
    use GenServer

    def start_link do
      GenServer.start_link(TestWorker, [], [])
    end

    def init do
       Process.flag(:trap_exit, true)
       {:ok, []}
    end

    def terminate(_reason, _state) do
      :ok
    end
  end

  test "start_child adds a child to this supervisor" do
    {:ok, pid} = Supervisor.add TestWorker

    assert Supervisor.children == [
      {TestWorker, pid, :worker, [TestWorker]}
    ]

    Supervisor.remove TestWorker
    assert Supervisor.children == []
  end
end
