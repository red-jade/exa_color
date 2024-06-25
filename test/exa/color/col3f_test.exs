defmodule Exa.Color.Col3fTest do
  use ExUnit.Case

  import Exa.Color.Col3f

  alias Exa.Color.ColorSpace
  alias Exa.Color.Col1b
  alias Exa.Color.Col3b
  alias Exa.Color.Col3Name

  test "simple" do
    assert {1.0, 1.0, 1.0} = white()
    assert {1.0, 1.0, 1.0} = new("white")

    assert {1.0, 0.0, 0.0} = red()
    assert {1.0, 0.0, 0.0} = new("red")
    assert {0.75, 0.0, 0.0} = new("RED") |> dark()
    assert {0.75, 0.25, 0.25} = new("Red ") |> pale()
    assert {0.625, 0.375, 0.375} = red() |> pale() |> pale()

    assert {0.5, 0.5, 0.5} = gray()
    assert {0.25, 0.25, 0.25} = gray_pc(25)
    assert {0.5, 0.5, 0.5} = new("grey")
    # gray is the palest color :)
    assert {0.5, 0.5, 0.5} = new("gray") |> pale()

    assert white() == gray_pc(100)
    assert black() == gray_pc(0)
  end

  test "conversions" do
    assert "#FFFFFF" = white() |> to_hex()
    assert "#FF0000" = red() |> to_hex()
    assert "#808080" = gray() |> to_hex()

    assert white() == from_hex("#FFFFFF")
    assert red() == from_hex("#FF0000")
    assert green() == from_hex("#00FF00")
    assert blue() == from_hex("#0000FF")
    assert black() == from_hex("#000000")

    assert {255, 255, 255} == white() |> to_col3b()
    assert {0, 0, 0} == black() |> to_col3b()
    assert {128, 128, 128} == gray() |> to_col3b()
    assert {255, 0, 0} == red() |> to_col3b()

    assert <<255, 0, 0>> == red() |> to_col3b() |> Col3b.to_bin()
    assert <<128, 128, 128>> == gray() |> to_col3b() |> Col3b.to_bin()
    assert <<0xCD, 0x85, 0x3F>> == Col3Name.new("peru") |> elem(1) |> Col3b.to_bin()

    assert {Col3Name.new("peru") |> elem(1), <<>>} == Col3b.from_bin(<<0xCD, 0x85, 0x3F>>)

    assert_raise FunctionClauseError, fn -> from_hex("FFFFFF") end
    assert_raise ArgumentError, fn -> from_hex("#1234XY") end
  end

  test "col1b" do
    assert 255 = Col1b.white()
    assert 0 = Col1b.black()
    assert 128 = Col1b.gray()
    assert 47 = Col1b.new(47)
    assert 255 = Col1b.new(447)
    assert {47, 47, 47} = 47 |> Col1b.new() |> Col1b.to_col3b()
    assert {128, 128, 128} = 128 |> Col1b.new() |> Col1b.to_col3b()
    assert <<47>> = 47 |> Col1b.new() |> Col1b.to_bin()
    assert <<47, 93, 178>> = Col1b.append_bin(<<47, 93>>, Col1b.new(178))
    assert {47, <<93, 178>>} = Col1b.from_bin(<<47, 93, 178>>)
  end

  test "lerp blend" do
    assert gray() == lerp(black(), 0.5, white())
    assert gray_pc(25) == lerp(black(), 0.25, white())
    assert gray_pc(75) == lerp(black(), 0.75, white())
    assert gray_pc(25) == lerp(white(), 0.75, black())

    assert gray() == blend([{0.25, white()}, {0.25, red()}, {0.25, green()}, {0.25, blue()}])
    assert gray() == blend([white(), red(), green(), blue()])

    assert dark(dark(magenta())) == blend([{0.5625, red()}, {0.5625, blue()}])
    assert {0.5, 0.0, 0.5} == blend([red(), blue()])
  end

  test "rgb2hsl" do
    black = black() |> ColorSpace.rgb2hsl()
    assert {0.0, 0.0, 0.0} = black

    gray25 = gray(0.25) |> ColorSpace.rgb2hsl()
    assert {0.0, 0.0, 0.25} = gray25

    gray50 = gray() |> ColorSpace.rgb2hsl()
    assert {0.0, 0.0, 0.5} = gray50

    gray75 = gray(0.75) |> ColorSpace.rgb2hsl()
    assert {0.0, 0.0, 0.75} = gray75

    white = white() |> ColorSpace.rgb2hsl()
    assert {0.0, 0.0, 1.0} = white

    red = red() |> ColorSpace.rgb2hsl()
    assert {0.0, 1.0, 0.5} = red

    yellow = yellow() |> ColorSpace.rgb2hsl()
    assert {0.16666666666666666, 1.0, 0.5} = yellow

    green = green() |> ColorSpace.rgb2hsl()
    assert {0.3333333333333333, 1.0, 0.5} = green

    cyan = cyan() |> ColorSpace.rgb2hsl()
    assert {0.5, 1.0, 0.5} = cyan

    blue = blue() |> ColorSpace.rgb2hsl()
    assert {0.6666666666666666, 1.0, 0.5} = blue

    magenta = magenta() |> ColorSpace.rgb2hsl()
    assert {0.8333333333333334, 1.0, 0.5} = magenta

    # change saturation

    pale_red = red() |> pale() |> ColorSpace.rgb2hsl()
    assert {0.0, 0.5, 0.5} = pale_red

    dark_green = green() |> dark() |> ColorSpace.rgb2hsl()
    assert {0.3333333333333333, 1.0, 0.375} = dark_green
  end

  test "ColorSpace.hsl2rgb" do
    assert black() == {0.0, 0.0, 0.0} |> ColorSpace.hsl2rgb()

    assert gray(0.25) == {0.0, 0.0, 0.25} |> ColorSpace.hsl2rgb()

    assert gray() == {0.0, 0.0, 0.5} |> ColorSpace.hsl2rgb()

    assert gray(0.75) == {0.0, 0.0, 0.75} |> ColorSpace.hsl2rgb()

    assert white() == {0.0, 0.0, 1.0} |> ColorSpace.hsl2rgb()

    assert red() == {0.0, 1.0, 0.5} |> ColorSpace.hsl2rgb()

    assert equals?(yellow(), {1 / 6, 1.0, 0.5} |> ColorSpace.hsl2rgb())

    assert green() == {1 / 3, 1.0, 0.5} |> ColorSpace.hsl2rgb()

    assert equals?(cyan(), {0.5, 1.0, 0.5} |> ColorSpace.hsl2rgb())

    assert blue() == {2 / 3, 1.0, 0.5} |> ColorSpace.hsl2rgb()

    assert equals?(magenta(), {5 / 6, 1.0, 0.5} |> ColorSpace.hsl2rgb())
  end
end
