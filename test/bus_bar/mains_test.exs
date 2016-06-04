defmodule BusBar.MainsTest do
  use ExUnit.Case
  doctest BusBar.Mains

  test "#start_link stores a gen event pid" do
    pid = Agent.get(BusBar.Mains, fn (pid) -> pid end)
    assert pid != nil
  end
end
