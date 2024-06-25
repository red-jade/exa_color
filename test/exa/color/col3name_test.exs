defmodule Exa.Color.Col3NameTest do
  use ExUnit.Case

  import Exa.Color.Col3Name

  test "simple" do
    assert {:pink, {255, 192, 203}} == "pink" |> new()

    assert "#DDA0DD" == "plum" |> new() |> to_hex()

    assert "rebeccapurple" == "rebeccapurple" |> new() |> to_name()

    assert {:red, {255, 0, 0}} == "red" |> new()

    assert {0.0, 0.0, 1.0} == "blue" |> new() |> to_col3f()

    assert_raise ArgumentError, fn -> new("rouge") end
  end

  # TODO - @codegen
  # test "load", do: load()
end
