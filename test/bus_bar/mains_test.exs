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

  test "#start_link stores a gen event pid" do
    pid = Agent.get(BusBar.Mains, fn (pid) -> pid end)
    assert pid != nil
  end

  test "#attach will subscribe to gen event" do
    log = capture_log(fn ->
      pid = Agent.get(BusBar.Mains, fn (pid) -> pid end)
      BusBar.Mains.attach TestHandler
      GenEvent.notify pid, {:attach_test, '1'}
      GenEvent.sync_notify pid, :attach_test
    end)
    assert log =~ ~r/Attach test success 1/
  end

  test "#attach will allow multiple subscriptions" do
    log = capture_log(fn ->
      pid = Agent.get(BusBar.Mains, fn (pid) -> pid end)
      BusBar.Mains.attach TestHandler
      BusBar.Mains.attach OtherTestHandler
      GenEvent.notify pid, {:attach_test, '2'}
      GenEvent.sync_notify pid, :attach_test
    end)
    assert log =~ ~r/Attach test success 2/
    assert log =~ ~r/Other attach test success 2/
  end

  test "#notify will transmit events via genevent" do
    log = capture_log(fn ->
      pid = Agent.get(BusBar.Mains, fn (pid) -> pid end)
      GenEvent.add_handler pid, TestHandler, []
      BusBar.Mains.notify :notify_test, 1
      GenEvent.sync_notify pid, :notify_test
    end)
    assert log =~ ~r/Notify test success/
  end

  test "notify will transmit events via genevent to multiple listeners" do
    log = capture_log(fn ->
      pid = Agent.get(BusBar.Mains, fn (pid) -> pid end)
      GenEvent.add_handler pid, TestHandler, []
      GenEvent.add_handler pid, OtherTestHandler, []
      BusBar.Mains.notify :notify_test, 2
      GenEvent.sync_notify pid, :notify_test
    end)
    assert log =~ ~r/Notify test success 2/
    assert log =~ ~r/Other notify test success 2/
  end

  test "notify will transmit events via genevent to multiple listeners even " <>
       "if one errors" do
    log = capture_log(fn ->
      pid = Agent.get(BusBar.Mains, fn (pid) -> pid end)
      GenEvent.add_handler pid, TestHandler, []
      GenEvent.add_handler pid, ErrorTestHandler, []
      GenEvent.add_handler pid, OtherTestHandler, []
      BusBar.Mains.notify :notify_test, :error
      GenEvent.sync_notify pid, :notify_test
    end)
    assert log =~ ~r/Notify test success error/
    assert log =~ ~r/Other notify test success error/
  end
end
