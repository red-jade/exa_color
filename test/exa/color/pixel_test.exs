defmodule Exa.Color.PixelTest do
  use ExUnit.Case

  import Exa.Color.Pixel

  alias Exa.Color.Col3b

  test "simple" do
    src_col = Col3b.magenta()
    dst_col = Col3b.black()

    const_rgb = Col3b.white()
    const_a = 0.5

    col =
      alpha_blend(
        src_col,
        :rgb,
        dst_col,
        :rgb,
        {:func_add, :func_add, :const_alpha, :one_minus_const_alpha, const_rgb, :const_alpha,
         :zero, const_a}
      )

    assert {128, 0, 128} = col
  end

  test "compile" do
    pf1 = {:gray, fn i -> 1 + i end, :gray}
    pf2 = {:gray, fn i -> {i, 2 * i, 3 * i} end, :rgb}
    pf3 = {:rgb, fn {r, g, b} -> (r + g + b) / 3.0 end, :gray}
    {:gray, comp, :gray} = compile([pf1, pf2, pf3])
    assert 4.0 = comp.(1)
    assert 6.0 = comp.(2)
  end
end
