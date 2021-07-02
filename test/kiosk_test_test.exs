defmodule KioskTestTest do
  use ExUnit.Case
  doctest KioskTest

  test "greets the world" do
    assert KioskTest.hello() == :world
  end
end
