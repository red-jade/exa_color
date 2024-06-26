defmodule Exa.Color.Col4b do
  @moduledoc """
  A 4-component byte RGB color with Alpha channel.
  The pixel order may be RGBA, ABGR, ...

  The alpha channel is opacity, 
  so `1.0` is opaque and `0.0` is transparent.
  """

  require Logger
  import Exa.Types

  alias Exa.Color.Types, as: C

  alias Exa.Math
  alias Exa.Convert

  alias Exa.Color.Colorb

  # -----------
  # constructor
  # -----------

  @spec new(integer(), integer(), integer(), integer()) :: C.col4b()

  def new(c1, c2, c3, c4) when is_byte(c1) and is_byte(c2) and is_byte(c3) and is_byte(c4) do
    {c1, c2, c3, c4}
  end

  def new(c1, c2, c3, c4)
      when is_integer(c1) and is_integer(c2) and is_integer(c3) and is_integer(c4) do
    clamp({c1, c2, c3, c4})
  end

  @doc """
  Add an alpha channel to a 3-byte color.

  The alpha value may be:
  - boolean (false -> transparent 0, true -> opaque 255)

  - bit (0 -> transparent 0, 1 -> opaque 255)

  - byte 0..255

  - unit float 0.0-1.0, maps to 0..255

  The `dst_pix` type is assumed to also represent the original 3-byte order.
  For example, `dst_pix` `:rgba` means `src_pix` `:rgb`.
  """
  @spec new(C.col3b(), C.alpha_value(), C.pixel4()) :: C.col4b()
  def new(col, a, pix \\ :rgba)
  def new({r, g, b}, a, :rgba), do: {r, g, b, a1b(a)}
  def new({r, g, b}, a, :argb), do: {a1b(a), r, g, b}
  def new({b, g, r}, a, :bgra), do: {b, g, r, a1b(a)}
  def new({b, g, r}, a, :abgr), do: {a1b(a), b, g, r}

  @doc "Convert input alpha value to a byte (0..255)."
  @spec a1b(C.alpha_value()) :: byte()

  def a1b(false), do: 0
  def a1b(true), do: 255
  def a1b(0), do: 0
  def a1b(1), do: 255
  def a1b(a) when is_byte(a), do: a
  def a1b(a) when is_float(a), do: Convert.f2b(a)

  def a1b(a) do 
    msg = "Illegal alpha value '#{a}'"
    Logger.error(msg)
    raise ArgumentError, message: msg
  end

  # --------------
  # public methods
  # --------------

  @doc "Remove the alpha channel, keeping the same color order."
  @spec to_col3b(C.col4b(), C.pixel4()) :: C.col3b()
  def to_col3b(col, pix \\ :rgba)
  def to_col3b({ir, ig, ib, _}, :rgba), do: {ir, ig, ib}
  def to_col3b({ib, ig, ir, _}, :bgra), do: {ib, ig, ir}
  def to_col3b({_, ir, ig, ib}, :argb), do: {ir, ig, ib}
  def to_col3b({_, ib, ig, ir}, :abgr), do: {ib, ig, ir}

  @doc "Convert datatype with the same pixel format."
  @spec to_col4f(C.col4b()) :: C.col4f()
  def to_col4f({c1, c2, c3, c4}),
    do: {Convert.b2f(c1), Convert.b2f(c2), Convert.b2f(c3), Convert.b2f(c4)}

  @doc "Convert datatype with the same pixel format."
  @spec from_col4f(C.col4f()) :: C.col4b()
  def from_col4f({c1, c2, c3, c4}),
    do: {Convert.f2b(c1), Convert.f2b(c2), Convert.f2b(c3), Convert.f2b(c4)}

  @doc "To RGBA hex."
  @spec to_hex(C.col4b(), C.pixel4()) :: C.hex4()
  def to_hex({ir, ig, ib, ia}, :rgba),
    do: "#" <> Convert.b2h(ir) <> Convert.b2h(ig) <> Convert.b2h(ib) <> Convert.b2h(ia)

  def to_hex({ib, ig, ir, ia}, :bgra), do: to_hex({ir, ig, ib, ia}, :rgba)
  def to_hex({ia, ir, ig, ib}, :argb), do: to_hex({ir, ig, ib, ia}, :rgba)
  def to_hex({ia, ib, ig, ir}, :abgr), do: to_hex({ir, ig, ib, ia}, :rgba)

  @doc "From RGBA hex."
  @spec from_hex(C.hex4(), C.pixel4()) :: C.col4b()
  def from_hex(hex, pix \\ :rgba)

  def from_hex("#" <> hex, :rgba) when is_fix_string(hex, 8) do
    {
      Convert.h2b(binary_part(hex, 0, 2)),
      Convert.h2b(binary_part(hex, 2, 2)),
      Convert.h2b(binary_part(hex, 4, 2)),
      Convert.h2b(binary_part(hex, 6, 2))
    }
  end

  def from_hex(hex, :bgra) do
    {ir, ig, ib, ia} = from_hex(hex, :rgba)
    {ib, ig, ir, ia}
  end

  def from_hex(hex, :argb) do
    {ir, ig, ib, ia} = from_hex(hex, :rgba)
    {ia, ir, ig, ib}
  end

  def from_hex(hex, :abgr) do
    {ir, ig, ib, ia} = from_hex(hex, :rgba)
    {ia, ib, ig, ir}
  end

  @doc """
  Write in CSS value format.
  Note that CSS format uses byte values for RGB but float for A.
  """
  @spec to_css(C.col4b(), C.pixel()) :: String.t()
  def to_css({ir, ig, ib, ia}, :rgba), do: "rgba(#{ir} #{ig} #{ib} #{dp3(ia)})"
  def to_css({ib, ig, ir, ia}, :bgra), do: to_css({ir, ig, ib, ia}, :rgba)
  def to_css({ia, ir, ig, ib}, :argb), do: to_css({ir, ig, ib, ia}, :rgba)
  def to_css({ia, ib, ig, ir}, :abgr), do: to_css({ir, ig, ib, ia}, :rgba)

  @spec dp3(byte()) :: float()
  defp dp3(x) when is_byte(x), do: x |> Convert.b2f() |> Float.round(3)

  # binary conversions ----------

  # TODO - note the pixel format does not affect thesd
  #        unless the src and dst pixels are different
  #        then need 2 args 

  @c4 [:rgba, :argb, :bgra, :abgr]

  @behaviour Colorb

  @impl Colorb
  def to_bin(col, pix \\ :rgba) when pix in @c4, do: append_bin(<<>>, pix, col)

  @impl Colorb
  def append_bin(buf, pix \\ :rgba, col)

  def append_bin(buf, pix, {c1, c2, c3, c4}) when pix in @c4 and is_binary(buf),
    do: <<buf::binary, c1, c2, c3, c4>>

  @impl Colorb
  def from_bin(buf, pix \\ :rgba)

  def from_bin(<<c1, c2, c3, c4, rest::binary>>, pix) when pix in @c4,
    do: {{c1, c2, c3, c4}, rest}

  # -----------------
  # private functions
  # -----------------

  # @spec mul(number(), C.col4b()) :: C.col4f()
  # defp mul(x, {c1, c2, c3, c4}), do: {x * c1, x * c2, x * c3, x * c4}

  # # add two colors with the same pixel format."
  # @spec add(C.col4b(), C.col4b()) :: C.col4b()
  # defp add({c1, c2, c3, c4}, {d1, d2, d3, d4}), do: {c1 + d1, c2 + d2, c3 + d3, c4 + d4}

  # integers, or float versions of bytes 0.0-255.0 (not unit float component)
  @spec clamp({number(), number(), number(), number()}) :: C.col4b()

  def clamp({c1, c2, c3, c4})
      when is_float(c1) and is_float(c2) and is_float(c3) and is_float(c4) do
    clamp({round(c1), round(c2), round(c3), round(c4)})
  end

  def clamp({c1, c2, c3, c4})
      when is_integer(c1) and is_integer(c2) and is_integer(c3) and is_integer(c4) do
    {Math.byte(c1), Math.byte(c2), Math.byte(c3), Math.byte(c4)}
  end
end
