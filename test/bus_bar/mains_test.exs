defmodule BusBar.MainsTest do
  use ExUnit.Case
  doctest BusBar.Mains

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
      BusBar.Mains.attach TestHandler
      GenEvent.notify :bus_bar, {:attach_test, '1'}
      GenEvent.sync_notify :bus_bar, :attach_test
    end)
    assert log =~ ~r/Attach test success 1/
  end

  test "#attach will allow multiple subscriptions" do
    log = capture_log(fn ->
      BusBar.Mains.attach TestHandler
      BusBar.Mains.attach OtherTestHandler
      GenEvent.notify :bus_bar, {:attach_test, '2'}
      GenEvent.sync_notify :bus_bar, :attach_test
      GenEvent.remove_handler :bus_bar, TestHandler, []
    end)
    assert log =~ ~r/Attach test success 2/
    assert log =~ ~r/Other attach test success 2/
  end

  test "#detach will remove a listener" do
    GenEvent.add_handler :bus_bar, TestHandler, []
    BusBar.Mains.detach TestHandler
    assert GenEvent.which_handlers(:bus_bar), []
  end

  test "#notify will transmit events via genevent" do
    log = capture_log(fn ->
      GenEvent.add_handler :bus_bar, TestHandler, []
      BusBar.Mains.notify :notify_test, 1
      GenEvent.sync_notify :bus_bar, :notify_test
      GenEvent.remove_handler :bus_bar, TestHandler, []
    end)
    assert log =~ ~r/Notify test success/
  end

  test "#notify will transmit events via genevent to multiple listeners" do
    log = capture_log(fn ->
      GenEvent.add_handler :bus_bar, TestHandler, []
      GenEvent.add_handler :bus_bar, OtherTestHandler, []
      BusBar.Mains.notify :notify_test, 2
      GenEvent.sync_notify :bus_bar, :notify_test
    end)
    assert log =~ ~r/Notify test success 2/
    assert log =~ ~r/Other notify test success 2/
  end

  test "#notify will transmit events via genevent to multiple listeners " <>
       "even if one errors" do
    log = capture_log(fn ->
      GenEvent.add_handler :bus_bar, TestHandler, []
      GenEvent.add_handler :bus_bar, ErrorTestHandler, []
      GenEvent.add_handler :bus_bar, OtherTestHandler, []
      BusBar.Mains.notify :notify_test, :error
      GenEvent.sync_notify :bus_bar, :notify_test
    end)
    assert log =~ ~r/Notify test success error/
    assert log =~ ~r/Other notify test success error/
  end

  test "listeners will return all attached handlers" do
    GenEvent.add_handler :bus_bar, TestHandler, []
    assert BusBar.Mains.listeners, [TestHandler]
    GenEvent.remove_handler :bus_bar, TestHandler, []
  end
end
