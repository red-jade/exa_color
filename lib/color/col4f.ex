defmodule Exa.Color.Col4f do
  @moduledoc "A 4-component floating-point RGBA color."

  use Exa.Constants

  import Exa.Types
  alias Exa.Types, as: E

  alias Exa.Color.Types, as: C

  alias Exa.Math
  alias Exa.Convert

  # -----------
  # constructor
  # -----------

  @spec new(float(), float(), float(), float()) :: C.col4f()
  def new(c1, c2, c3, c4) when is_float(c1) and is_float(c2) and is_float(c3) and is_float(c4),
    do: clamp({c1, c2, c3, c4})

  @doc """
  Add an alpha channel to a 3-byte color.

  The alpha value may be:
  - boolean (false -> transparent 0, true -> opaque 255)

  - bit (0 -> transparent 0, 1 -> opaque 255)

  - byte 0..255, maps to 0.0-1.0

  - unit float 0.0-1.0

  The `dst_pix` type is assumed to also represent the original 3-byte order.
  For example, `dst_pix` `:rgba` means `src_pix` `:rgb`.
  """
  @spec new(C.col3f(), I.alpha_value(), I.pixel4()) :: C.col4f()
  def new(col, a, pix \\ :rgba)
  def new({r, g, b}, a, :rgba), do: {r, g, b, a1f(a)}
  def new({r, g, b}, a, :argb), do: {a1f(a), r, g, b}
  def new({b, g, r}, a, :bgra), do: {b, g, r, a1f(a)}
  def new({b, g, r}, a, :abgr), do: {a1f(a), b, g, r}

  @doc "Convert input alpha value to a unit float (0.0-1.0)."
  @spec a1f(I.alpha_value()) :: E.unit()
  def a1f(false), do: 0.0
  def a1f(true), do: 1.0
  def a1f(0), do: 0.0
  def a1f(1), do: 1.0
  def a1f(a) when is_byte(a), do: Convert.b2f(a)
  def a1f(a) when is_float(a), do: Math.unit(a)
  def a1f(a), do: raise(ArgumentError, message: "Illegal alpha value '#{a}'")

  # --------------
  # public methods
  # --------------

  @spec equals?(C.col4f(), C.col4f(), E.epsilon()) :: bool()
  def equals?({c1, c2, c3, c4}, {d1, d2, d3, d4}, eps \\ @epsilon) do
    Math.equals?(c1, d1, eps) and Math.equals?(c2, d2, eps) and
      Math.equals?(c3, d3, eps) and Math.equals?(c4, d4, eps)
  end

  @doc "Remove the alpha channel, keeping the same color order."
  @spec to_col3f(C.col4f(), I.pixel4()) :: C.col3f()
  def to_col3f(col, pix \\ :rgba)
  def to_col3f({r, g, b, _}, :rgba), do: {r, g, b}
  def to_col3f({b, g, r, _}, :bgra), do: {b, g, r}
  def to_col3f({_, r, g, b}, :argb), do: {r, g, b}
  def to_col3f({_, b, g, r}, :abgr), do: {b, g, r}

  # TODO - alpha blending

  # @doc """
  # A mean blend of a list of colors (optionally weighted).

  # If the list is just colors, then the result is divided by the number of colors.

  # If the list is weighted, the sum of weights should equal 1.0.
  # The final color values are clamped to be in the range (0.0,1.0).
  # """
  # @spec blend(C.color_weights() | C.colors3()) :: C.col3f()

  # def blend(wcols) when is_wcols(wcols) do
  #   wcols
  #   |> Enum.reduce(black(), fn
  #     {w, col}, sum when is_float(w) and is_col3f(col) -> add(sum, mul(w, col))
  #     {w, col}, sum when is_float(w) and is_col3b(col) -> add(sum, mul(w, Col3b.to_col3f(col)))
  #   end)
  #   |> clamp()
  # end

  # def blend(cols) when is_colors3(cols) do
  #   mul(
  #     1.0 / length(cols),
  #     Enum.reduce(cols, black(), fn
  #       col, sum when is_col3f(col) -> add(sum, col)
  #       col, sum when is_col3b(col) -> add(sum, Col3b.to_col3f(col))
  #     end)
  #   )
  # end

  @doc "Convert datatype with the same pixel format."
  @spec to_col4b(C.col4f()) :: C.col4b()
  def to_col4b({c1, c2, c3, c4}),
    do: {Convert.f2b(c1), Convert.f2b(c2), Convert.f2b(c3), Convert.f2b(c4)}

  @doc "Convert datatype with the same pixel format."
  @spec from_col4b(C.col4b()) :: C.col4f()
  def from_col4b({c1, c2, c3, c4}),
    do: {Convert.b2f(c1), Convert.b2f(c2), Convert.b2f(c3), Convert.b2f(c4)}

  @doc "To RGBA hex."
  @spec to_hex(C.col4f(), I.pixel4()) :: C.hex4()
  def to_hex(col, pix \\ :rgba)

  def to_hex({r, g, b, a}, :rgba),
    do: "#" <> Convert.f2h(r) <> Convert.f2h(g) <> Convert.f2h(b) <> Convert.f2h(a)

  def to_hex({a, r, g, b}, :argb),
    do: "#" <> Convert.f2h(r) <> Convert.f2h(g) <> Convert.f2h(b) <> Convert.f2h(a)

  def to_hex({b, g, r, a}, :bgra),
    do: "#" <> Convert.f2h(r) <> Convert.f2h(g) <> Convert.f2h(b) <> Convert.f2h(a)

  def to_hex({a, b, g, r}, :abgr),
    do: "#" <> Convert.f2h(r) <> Convert.f2h(g) <> Convert.f2h(b) <> Convert.f2h(a)

  @doc "From RGBA hex."
  @spec from_hex(C.hex4(), I.pixel4()) :: C.col4f()
  def from_hex(hex, pix \\ :rgba)

  def from_hex("#" <> hex, :rgba) when is_fix_string(hex, 8) do
    {
      Convert.h2f(binary_part(hex, 0, 2)),
      Convert.h2f(binary_part(hex, 2, 2)),
      Convert.h2f(binary_part(hex, 4, 2)),
      Convert.h2f(binary_part(hex, 6, 2))
    }
  end

  def from_hex(hex, :bgra) do
    {r, g, b, a} = from_hex(hex, :rgba)
    {b, g, r, a}
  end

  def from_hex(hex, :argb) do
    {r, g, b, a} = from_hex(hex, :rgba)
    {a, r, g, b}
  end

  def from_hex(hex, :abgr) do
    {r, g, b, a} = from_hex(hex, :rgba)
    {a, b, g, r}
  end

  @doc "Write in CSS RGB value format."
  @spec to_css(C.col3f(), I.pixel()) :: String.t()
  def to_css(col, pix \\ :rgba)

  def to_css({r, g, b, a}, :rgba),
    do: "rgb(#{Convert.f2b(r)} #{Convert.f2b(g)} #{Convert.f2b(b)} #{dp3(a)})"

  def to_css({a, r, g, b}, :argb), do: to_css({r, g, b, a}, :rgba)
  def to_css({a, b, g, r}, :abgr), do: to_css({r, g, b, a}, :rgba)
  def to_css({b, g, r, a}, :bgra), do: to_css({r, g, b, a}, :rgba)

  # -----------------
  # private functions
  # -----------------

  @spec dp3(float()) :: float()
  defp dp3(x) when is_float(x), do: Float.round(x, 3)

  # @spec mul(float(), C.col4f()) :: C.col4f()
  # defp mul(x, {c1, c2, c3, c4}), do: {x * c1, x * c2, x * c3, x * c4}

  # add two colors with the same pixel format."
  # @spec add(C.col4f(), C.col4f()) :: C.col4f()
  # defp add({c1, c2, c3, c4}, {d1, d2, d3, d4}), do: {c1 + d1, c2 + d2, c3 + d3, c4 + d4}

  @spec clamp({float(), float(), float(), float()}) :: C.col4f()
  def clamp({c1, c2, c3, c4})
      when is_float(c1) and is_float(c2) and is_float(c3) and is_float(c4) do
    {Math.unit(c1), Math.unit(c2), Math.unit(c3), Math.unit(c4)}
  end
end
