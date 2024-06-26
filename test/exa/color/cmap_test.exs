defmodule Exa.Color.CmapTest do
  use ExUnit.Case

  alias Exa.Color.Col3f

  import Exa.Color.Colormap3b

  test "simple" do
    cols =
      Enum.map(0..255, fn i ->
        l = i / 255.0
        {l, l, l}
      end)

    gray = new(cols)
    assert {170, 170, 170} = lookup(gray, 170)
    assert {221, 221, 221} = lookup(gray, 221)

    r2b = gradient(Col3f.red(), Col3f.blue(), :rgb)
    assert {85, 0, 170} = lookup(r2b, 170)
    assert {34, 0, 221} = lookup(r2b, 221)

    {:colormap, :index, :rgb, cmap} = blue_white_red()
    assert 256 = map_size(cmap)
    assert Range.to_list(0..255) == cmap |> Map.keys() |> Enum.sort()
  end
end
