defmodule BusBar.MainsTest do
  use ExUnit.Case
  doctest BusBar.Mains

  import ExUnit.CaptureLog

  defmodule TestHandler do
    use GenEvent
    require Logger

    def handle_event({:attach_test, _ }, parent) do
      Logger.info "Attach test success"
      { :ok, parent }
    end

  end

  test "#start_link stores a gen event pid" do
    pid = Agent.get(BusBar.Mains, fn (pid) -> pid end)
    assert pid != nil
  end

  test "#attach will subscribe to gen event" do
    log = capture_log(fn ->
      pid = Agent.get(BusBar.Mains, fn (pid) -> pid end)
      BusBar.Mains.attach TestHandler
      GenEvent.notify pid, {:attach_test, {}}
      GenEvent.sync_notify pid, :attach_test
    end)
    assert log =~ ~r/Attach test success/
  end
end
