defmodule BusBar.EventWatcherTest do
  use ExUnit.Case
  doctest BusBar.EventWatcher

  import ExUnit.CaptureLog

  defmodule TestHandler do
    use GenEvent
    require Logger

    def handle_event({:notify_test, data}, parent) do
      Logger.info "Notify test success #{data}"
      { :ok, parent }
    end
  end

  defmodule ErrorTestHandler do
    use GenEvent
    require Logger

    def handle_event({:notify_test, data}, _) do
      2 = data
      Logger.info "Notify test success 2 = #{data}"
    end
  end

  test "meter ensures listeners are restarted when they error" do
    log = capture_log(fn ->
      BusBar.attach TestHandler
      BusBar.attach ErrorTestHandler
      BusBar.sync_notify :notify_test, 1
      Process.sleep 1
      BusBar.sync_notify :notify_test, 2
      BusBar.detach TestHandler
      BusBar.detach ErrorTestHandler
    end)
    assert log =~ ~r/Notify test success 1/
    assert log =~ ~r/Notify test success 2/
    assert log =~ ~r/Notify test success 2 = 2/
    assert BusBar.EventManager.listeners, [TestHandler, ErrorTestHandler]
  end

end
