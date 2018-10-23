defmodule ServyTest do
  use ExUnit.Case
  doctest Servy

  test "greets by name" do
    assert Servy.hello("Danilo") == "Hello Danilo!"
  end
end
