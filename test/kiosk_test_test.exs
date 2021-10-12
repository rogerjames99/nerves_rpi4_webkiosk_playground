defmodule NervesWebKioskPlaygroundTest do
  use ExUnit.Case
  doctest NervesWebKioskPlayground

  test "greets the world" do
    assert NervesWebKioskPlayground.hello() == :world
  end
end
