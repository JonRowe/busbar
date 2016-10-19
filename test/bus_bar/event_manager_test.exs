defmodule BusBar.EventManagerTest do
  use ExUnit.Case
  doctest BusBar.EventManager

  import ExUnit.CaptureLog

  defmodule TestHandler do
    use GenEvent
    require Logger

    def handle_event({:attach_test, data }, parent) do
      Logger.info "Attach test success #{data}"
      { :ok, parent }
    end

    def handle_event({:notify_test, data }, parent) do
      Logger.info "Notify test success #{data}"
      { :ok, parent }
    end
  end

  defmodule ErrorTestHandler do
    use GenEvent

    def handle_event({:notify_test, :error}, _) do
      raise "boom"
    end
  end

  defmodule OtherTestHandler do
    use GenEvent
    require Logger

    def handle_event({:attach_test, data }, parent) do
      Logger.info "Other attach test success #{data}"
      { :ok, parent }
    end

    def handle_event({:notify_test, data }, parent) do
      Logger.info "Other notify test success #{data}"
      { :ok, parent }
    end
  end

  test "#attach will subscribe to gen event" do
    log = capture_log(fn ->
      BusBar.EventManager.attach TestHandler
      GenEvent.sync_notify :bus_bar_events, {:attach_test, '1'}
    end)
    assert log =~ ~r/Attach test success 1/
  end

  test "#attach will allow multiple subscriptions" do
    log = capture_log(fn ->
      BusBar.EventManager.attach TestHandler
      BusBar.EventManager.attach OtherTestHandler
      GenEvent.sync_notify :bus_bar_events, {:attach_test, '2'}
      GenEvent.remove_handler :bus_bar_events, TestHandler, []
      GenEvent.remove_handler :bus_bar_events, OtherTestHandler, []
    end)
    assert log =~ ~r/Attach test success 2/
    assert log =~ ~r/Other attach test success 2/
  end

  test "#detach will remove a listener" do
    GenEvent.add_handler :bus_bar_events, TestHandler, []
    BusBar.EventManager.detach TestHandler
    assert GenEvent.which_handlers(:bus_bar_events), []
  end

  test "#notify will transmit events via genevent" do
    log = capture_log(fn ->
      GenEvent.add_handler :bus_bar_events, TestHandler, []
      BusBar.EventManager.notify :notify_test, 1
      GenEvent.remove_handler :bus_bar_events, TestHandler, []
    end)
    assert log =~ ~r/Notify test success/
  end

  test "#notify will transmit events via genevent to multiple listeners" do
    log = capture_log(fn ->
      GenEvent.add_handler :bus_bar_events, TestHandler, []
      GenEvent.add_handler :bus_bar_events, OtherTestHandler, []
      BusBar.EventManager.notify :notify_test, 2
      GenEvent.sync_notify :bus_bar_events, :notify_test
      GenEvent.remove_handler :bus_bar_events, TestHandler, []
      GenEvent.remove_handler :bus_bar_events, OtherTestHandler, []
    end)
    assert log =~ ~r/Notify test success 2/
    assert log =~ ~r/Other notify test success 2/
  end

  test "#notify will transmit events via genevent to multiple listeners " <>
       "even if one errors" do
    log = capture_log(fn ->
      GenEvent.add_handler :bus_bar_events, TestHandler, []
      GenEvent.add_handler :bus_bar_events, ErrorTestHandler, []
      GenEvent.add_handler :bus_bar_events, OtherTestHandler, []
      BusBar.EventManager.notify :notify_test, :error
      GenEvent.remove_handler :bus_bar_events, TestHandler, []
      GenEvent.remove_handler :bus_bar_events, ErrorTestHandler, []
      GenEvent.remove_handler :bus_bar_events, OtherTestHandler, []
    end)
    assert log =~ ~r/Notify test success error/
    assert log =~ ~r/Other notify test success error/
  end

  test "#sync_notify will transmit events via genevent" do
    log = capture_log(fn ->
      GenEvent.add_handler :bus_bar_events, TestHandler, []
      BusBar.EventManager.sync_notify :notify_test, 1
      GenEvent.remove_handler :bus_bar_events, TestHandler, []
    end)
    assert log =~ ~r/Notify test success/
  end

  test "#sync_notify will transmit events via genevent to multiple listeners" do
    log = capture_log(fn ->
      GenEvent.add_handler :bus_bar_events, TestHandler, []
      GenEvent.add_handler :bus_bar_events, OtherTestHandler, []
      BusBar.EventManager.sync_notify :notify_test, 2
      GenEvent.remove_handler :bus_bar_events, TestHandler, []
      GenEvent.remove_handler :bus_bar_events, OtherTestHandler, []
    end)
    assert log =~ ~r/Notify test success 2/
    assert log =~ ~r/Other notify test success 2/
  end

  test "#sync_notify will transmit events via genevent to multiple " <>
       "listeners even if one errors" do
    log = capture_log(fn ->
      GenEvent.add_handler :bus_bar_events, TestHandler, []
      GenEvent.add_handler :bus_bar_events, ErrorTestHandler, []
      GenEvent.add_handler :bus_bar_events, OtherTestHandler, []
      BusBar.EventManager.sync_notify :notify_test, :error
      GenEvent.remove_handler :bus_bar_events, TestHandler, []
      GenEvent.remove_handler :bus_bar_events, ErrorTestHandler, []
      GenEvent.remove_handler :bus_bar_events, OtherTestHandler, []
    end)
    assert log =~ ~r/Notify test success error/
    assert log =~ ~r/Other notify test success error/
  end

  test "listeners will return all attached handlers" do
    GenEvent.add_handler :bus_bar_events, TestHandler, []
    assert BusBar.EventManager.listeners, [TestHandler]
    GenEvent.remove_handler :bus_bar_events, TestHandler, []
  end
end
