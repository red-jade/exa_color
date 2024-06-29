defmodule Exa.Color.Col3b do
  @moduledoc "A 3-component byte RGB or BGR color."

  import Exa.Types
  alias Exa.Types, as: E

  import Exa.Color.Types
  alias Exa.Color.Types, as: C

  alias Exa.Math
  alias Exa.Convert

  alias Exa.Color.Colorb
  alias Exa.Color.Col3Name
  alias Exa.Color.ColorSpace

  # ---------
  # constants
  # ---------

  @spec black() :: C.col3b()
  def black(), do: {0, 0, 0}

  @spec white() :: C.col3b()
  def white(), do: {255, 255, 255}

  @spec red() :: C.col3b()
  def red(), do: {255, 0, 0}

  @spec green() :: C.col3b()
  def green(), do: {0, 255, 0}

  @spec blue() :: C.col3b()
  def blue(), do: {0, 0, 255}

  @spec yellow() :: C.col3b()
  def yellow(), do: {255, 255, 0}

  @spec cyan() :: C.col3b()
  def cyan(), do: {0, 255, 255}

  @spec magenta() :: C.col3b()
  def magenta(), do: {255, 0, 255}

  @spec gray() :: C.col3b()
  def gray(), do: {128, 128, 128}

  @doc "Gray level as a byte 0..255"
  @spec gray(byte()) :: C.col3b()
  def gray(gray) when is_byte(gray), do: {gray, gray, gray}

  @doc "Gray level as a percentage 0..100"
  @spec gray_pc(E.percent()) :: C.col3b()
  def gray_pc(pc) when is_pc(pc), do: gray(round(255.0 * pc / 100.0))

  # -----------
  # constructor
  # -----------

  @doc "Create a new 3-byte color by clamping integer components to byte range."
  @spec new(integer(), integer(), integer()) :: C.col3b()

  def new(c1, c2, c3) when is_byte(c1) and is_byte(c2) and is_byte(c3), do: {c1, c2, c3}

  def new(c1, c2, c3) when is_integer(c1) and is_integer(c2) and is_integer(c3),
    do: clamp({c1, c2, c3})

  @doc """
  Create a new 3-byte color by name. 
  Only a few names are supported:
  black/white, primaries (RGB), secondaries (CMY) and gray.

  See `Exa.Color.Col3name` for full range of CSS colors.
  """
  @spec new(String.t()) :: C.col3b()
  def new(s) when is_binary(s) do
    s |> String.replace(" ", "") |> String.downcase() |> do_new()
  end

  defp do_new("white"), do: white()
  defp do_new("black"), do: black()

  defp do_new("red"), do: red()
  defp do_new("green"), do: green()
  defp do_new("blue"), do: blue()

  defp do_new("yellow"), do: yellow()
  defp do_new("cyan"), do: cyan()
  defp do_new("magenta"), do: magenta()

  defp do_new("gray"), do: gray()
  defp do_new("grey"), do: gray()

  defp do_new(str) when is_binary(str), do: str |> Col3Name.new() |> Col3Name.to_col3b()

  # --------------
  # public methods
  # --------------

  # equals? use ==

  # modify ----------

  @doc "Reduce value."
  @spec dark(C.col3b()) :: C.col3b()
  def dark(col) when is_col3b(col), do: clamp(mul(0.5, col))

  @doc "Increase saturation."
  @spec pale(C.col3b()) :: C.col3b()
  def pale(col) when is_col3b(col), do: clamp(mul(0.5, add(white(), col)))

  # conversions ----------

  @doc """
  Calculate the luminance (brightness) 
  using Digital ITU BT.601:

  `Y = 0.299 R + 0.587 G + 0.114 B`
  """
  @spec luma(C.col3b(), C.pixel3()) :: byte()
  def luma(col, pix \\ :rgb)
  def luma({ir, ig, ib}, :rgb), do: Convert.f2b((0.299 * ir + 0.587 * ig + 0.114 * ib) / 255.0)
  def luma({ib, ig, ir}, :bgr), do: luma({ir, ig, ib}, :rgb)

  @doc "Convert to gray with the same pixel format."
  @spec to_gray(C.col3b(), C.pixel3()) :: C.col3b()
  def to_gray(c, pix \\ :rgb) when is_col3b(c), do: c |> luma(pix) |> gray()

  @doc "Convert datatype with the same pixel format."
  @spec to_col3f(C.col3b()) :: C.col3f()
  def to_col3f({c1, c2, c3}), do: {Convert.b2f(c1), Convert.b2f(c2), Convert.b2f(c3)}

  @doc "Convert datatype with the same pixel format."
  @spec from_col3f(C.col3f()) :: C.col3b()
  def from_col3f({c1, c2, c3}), do: {Convert.f2b(c1), Convert.f2b(c2), Convert.f2b(c3)}

  @doc "To RGB hex string."
  @spec to_hex(C.col3b(), C.pixel3()) :: C.hex3()
  def to_hex({ir, ig, ib}, :rgb), do: "#" <> Convert.b2h(ir) <> Convert.b2h(ig) <> Convert.b2h(ib)
  def to_hex({ib, ig, ir}, :bgr), do: to_hex({ir, ig, ib}, :rgb)

  @doc "From RGB hex string."
  @spec from_hex(C.hex3(), C.pixel3()) :: C.col3b()
  def from_hex(col, pix \\ :rgb)

  def from_hex("#" <> hex, :rgb) when is_fix_string(hex, 6) do
    {
      Convert.h2b(binary_part(hex, 0, 2)),
      Convert.h2b(binary_part(hex, 2, 2)),
      Convert.h2b(binary_part(hex, 4, 2))
    }
  end

  def from_hex("#" <> hex, :bgr) when is_fix_string(hex, 6) do
    {
      Convert.h2b(binary_part(hex, 4, 2)),
      Convert.h2b(binary_part(hex, 2, 2)),
      Convert.h2b(binary_part(hex, 0, 2))
    }
  end

  @doc "Write in CSS rgb(...) value format."
  @spec to_css(C.col3b(), C.pixel()) :: String.t()
  def to_css({ir, ig, ib}, :rgb), do: "rgb(#{ir} #{ig} #{ib})"
  def to_css({ib, ig, ir}, :bgr), do: to_css({ir, ig, ib}, :rgb)

  @doc "Write in CSS hsl(...) value format."
  @spec to_css_hsl(C.col3b(), :rgb | :bgr) :: String.t()
  def to_css_hsl(col, pix \\ :rgb)

  def to_css_hsl(col, :rgb) when is_col3b(col) do 
    {h, s, l} = col |> to_col3f() |> ColorSpace.rgb2hsl() |> ColorSpace.unit2hsl()
    "hsl(#{h} #{s}% #{l}%)"
  end

  def to_css_hsl(col, :bgr), do: to_css_hsl(col, :rgb)

  # binary conversions ----------

  # TODO - note the pixel format does not affect these
  #        unless the src and dst pixels are different
  #        then need 2 args 

  @c3 [:rgb, :bgr]

  @behaviour Colorb

  @impl Colorb
  def to_bin(col, pix \\ :rgb) when pix in @c3,
    do: append_bin(<<>>, pix, col)

  @impl Colorb
  def append_bin(buf, pix \\ :rgb, {c1, c2, c3}) when pix in @c3 and is_binary(buf),
    do: <<buf::binary, c1, c2, c3>>

  @impl Colorb
  def from_bin(<<c1, c2, c3, rest::binary>>, pix \\ :rgb) when pix in @c3,
    do: {{c1, c2, c3}, rest}

  # -----------------
  # private functions
  # -----------------

  # scalar multiply to give a float color
  @spec mul(number(), C.col3b()) :: C.col3f()
  defp mul(x, {c1, c2, c3}), do: {x * c1, x * c2, x * c3}

  # add two colors with the same pixel format
  @spec add(C.col3b(), C.col3b()) :: C.col3b()
  defp add({c1, c2, c3}, {d1, d2, d3}), do: {c1 + d1, c2 + d2, c3 + d3}

  # integers, or float versions of bytes 0.0-255.0 (not unit float component)
  @spec clamp({number(), number(), number()}) :: C.col3b()

  defp clamp({c1, c2, c3}) when is_float(c1) and is_float(c2) and is_float(c3) do
    clamp({round(c1), round(c2), round(c3)})
  end

  defp clamp({c1, c2, c3}) when is_integer(c1) and is_integer(c2) and is_integer(c3) do
    {Math.byte(c1), Math.byte(c2), Math.byte(c3)}
  end
end
