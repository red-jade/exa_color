defmodule Exa.Color.Col3f do
  @moduledoc "A 3-component floating-point RGB color."

  use Exa.Constants

  import Exa.Types
  alias Exa.Types, as: E

  import Exa.Color.Types
  alias Exa.Color.Types, as: C

  alias Exa.Math
  alias Exa.Convert

  alias Exa.Color.Col3b
  alias Exa.Color.Col3name
  alias Exa.Color.ColorSpace

  # ---------
  # constants
  # ---------

  @spec black() :: C.col3f()
  def black(), do: {0.0, 0.0, 0.0}

  @spec white() :: C.col3f()
  def white(), do: {1.0, 1.0, 1.0}

  @spec red() :: C.col3f()
  def red(), do: {1.0, 0.0, 0.0}

  @spec green() :: C.col3f()
  def green(), do: {0.0, 1.0, 0.0}

  @spec blue() :: C.col3f()
  def blue(), do: {0.0, 0.0, 1.0}

  @spec yellow() :: C.col3f()
  def yellow(), do: {1.0, 1.0, 0.0}

  @spec cyan() :: C.col3f()
  def cyan(), do: {0.0, 1.0, 1.0}

  @spec magenta() :: C.col3f()
  def magenta(), do: {1.0, 0.0, 1.0}

  @spec gray() :: C.col3f()
  def gray(), do: {0.5, 0.5, 0.5}

  @spec gray(E.unit()) :: C.col3f()
  def gray(gray) when is_unit(gray), do: {gray, gray, gray}

  @doc "Gray level as a percentage 0..100"
  @spec gray_pc(E.percent()) :: C.col3f()
  def gray_pc(pc) when is_pc(pc), do: gray(Math.unit(pc / 100.0))

  # -----------
  # constructor
  # -----------

  @doc "Create a new 3-float color by clamping float components to unit range."
  @spec new(float(), float(), float()) :: C.col3f()
  def new(r, g, b) when is_float(r) and is_float(g) and is_float(b), do: clamp({r, g, b})

  @doc """
  Create a new 3-float color by name. 
  Only a few names are supported:
  black/white, primaries (RGB), secondaries (CMY) and gray.

  See `Exa.Color.Col3name` for full range of CSS colors.
  """
  @spec new(String.t()) :: C.col3f()
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

  defp do_new(str) when is_binary(str), do: str |> Col3name.new() |> Col3name.to_col3f()

  # --------------
  # public methods
  # --------------

  @doc "Compare 3-component float colors for equality (within tolerance)."
  @spec equals?(C.col3f(), C.col3f(), E.epsilon()) :: bool()
  def equals?({r1, g1, b1}, {r2, g2, b2}, eps \\ @epsilon) do
    Math.equals?(r1, r2, eps) and Math.equals?(g1, g2, eps) and Math.equals?(b1, b2, eps)
  end

  # modify ----------

  @doc "Reduce value."
  @spec dark(C.col3f()) :: C.col3f()
  def dark(col) when is_col3f(col), do: mul(0.75, col)

  @doc "Increase saturation."
  @spec pale(C.col3f()) :: C.col3f()
  def pale(col) when is_col3f(col), do: mul(0.25, add(white(), mul(2.0, col)))

  # conversion ----------

  @doc """
  Calculate the luminance (brightness) 
  using Digital ITU BT.601:

  `Y = 0.299 R + 0.587 G + 0.114 B`
  """
  @spec luma(C.col3f(), C.pixel3()) :: E.unit()
  def luma(col, pix \\ :rgb)
  def luma({r, g, b}, :rgb), do: 0.299 * r + 0.587 * g + 0.114 * b
  def luma({b, g, r}, :bgr), do: luma({r, g, b}, :rgb)

  @doc "Convert to gray with the same pixel format."
  @spec to_gray(C.col3f(), C.pixel3()) :: C.col3f()
  def to_gray(c, pix \\ :rgb) when is_col3f(c), do: c |> luma(pix) |> gray()

  @doc "Convert datatype with the same pixel format."
  @spec to_col3b(C.col3f()) :: C.col3b()
  def to_col3b({c1, c2, c3}), do: {Convert.f2b(c1), Convert.f2b(c2), Convert.f2b(c3)}

  @doc "Convert datatype with the same pixel format."
  @spec from_col3b(C.col3b()) :: C.col3f()
  def from_col3b({c1, c2, c3}), do: {Convert.b2f(c1), Convert.b2f(c2), Convert.b2f(c3)}

  @doc "To RGB hex string."
  @spec to_hex(C.col3f(), C.pixel3()) :: C.hex3()
  def to_hex(col, pix \\ :rgb)
  def to_hex({r, g, b}, :rgb), do: "#" <> Convert.f2h(r) <> Convert.f2h(g) <> Convert.f2h(b)
  def to_hex({b, g, r}, :bgr), do: "#" <> Convert.f2h(r) <> Convert.f2h(g) <> Convert.f2h(b)

  @doc "From RGB hex string."
  @spec from_hex(C.hex3()) :: C.col3f()
  def from_hex("#" <> hex) when is_string_fix(hex, 6) do
    {
      Convert.h2f(binary_part(hex, 0, 2)),
      Convert.h2f(binary_part(hex, 2, 2)),
      Convert.h2f(binary_part(hex, 4, 2))
    }
  end

  # does the CSS rgb((...) format allow floating point?
  # "rgb(#{dp3(r)} #{dp3(g)} #{dp3(b)})"

  @doc "Write in CSS rgb(...) value format."
  @spec to_css(C.col3f(), :rgb | :bgr) :: String.t()
  def to_css(col, pix \\ :rgb)

  def to_css(col, :rgb) when is_col3f(col) do 
    {ir, ig, ib} = to_col3b(col)
    "rgb(#{ir} #{ig} #{ib})"
  end

  def to_css({b, g, r}, :bgr), do: to_css({r, g, b}, :rgb)

  @doc "Write in CSS hsl(...) value format."
  @spec to_css_hsl(C.col3f(), :rgb | :bgr) :: String.t()
  def to_css_hsl(col, pix \\ :rgb)

  def to_css_hsl(col, :rgb) when is_col3f(col) do 
    {ih, is, il} = col |> ColorSpace.rgb2hsl() |> ColorSpace.unit2hsl()
    "hsl(#{ih} #{is}% #{il}%)"
  end

  def to_css_hsl({b, g, r}, :bgr), do: to_css_hsl({r, g, b}, :rgb)

  # blend ----------

  @doc """
  Linear interpolation between two colors.
  The parameter _x_ is a value between 0.0 (color1) and 1.0 (color2).
  """
  @spec lerp(C.col3f(), E.unit(), C.col3f()) :: C.col3f()
  def lerp(col1, x, col2) when is_col3f(col1) and is_col3f(col2) and is_unit(x) do
    add(col1, mul(x, sub(col2, col1)))
  end

  @doc """
  Linear interpolation between two colors,
  using the initial color c1, 
  and the color difference c2-c1 (ray formulation).
  This factors out the difference to optimize 
  calculation of gradients between two colors.

  The parameter _x_ is a value between 0.0 (c1) and 1.0 (c2) 
  """
  @spec lerp_diff(C.col3f(), E.unit(), {float(), float(), float()}) :: C.col3f()
  def lerp_diff(col1, x, diff) when is_col3f(col1) and is_unit(x) do
    add(col1, mul(x, diff))
  end

  @doc """
  A blend of a list of colors (optionally weighted).

  If the list is just colors, then the result is divided by the number of colors.

  If the list is weighted, the sum of weights should equal 1.0 (not enforced).
  The final color values are clamped to be in the range (0.0,1.0).
  """
  @spec blend(C.color_weights() | C.colors3()) :: C.col3f()

  def blend(wcols) when is_wcols(wcols) do
    wcols
    |> Enum.reduce(black(), fn
      {w, col}, sum when is_float(w) and is_col3f(col) -> add(sum, mul(w, col))
      {w, col}, sum when is_float(w) and is_col3b(col) -> add(sum, mul(w, Col3b.to_col3f(col)))
    end)
    |> clamp()
  end

  def blend(cols) when is_colors3(cols) do
    mul(
      1.0 / length(cols),
      Enum.reduce(cols, black(), fn
        col, sum when is_col3f(col) -> add(sum, col)
        col, sum when is_col3b(col) -> add(sum, Col3b.to_col3f(col))
      end)
    )
  end

  # -----------------
  # private functions
  # -----------------

  # round to 3 decimal points
  # @spec dp3(float()) :: float()
  # defp dp3(x) when is_float(x), do: Float.round(x, 3)

  # scalar multiply with the same pixel format
  @spec mul(float(), C.col3f()) :: C.col3f()
  defp mul(x, {c1, c2, c3}), do: {x * c1, x * c2, x * c3}

  # add two colors with the same pixel format."
  @spec add(C.col3f(), C.col3f()) :: C.col3f()
  defp add({c1, c2, c3}, {d1, d2, d3}), do: {c1 + d1, c2 + d2, c3 + d3}

  # subtract two colors with the same pixel format
  @spec sub(C.col3f(), C.col3f()) :: C.col3f()
  defp sub({c1, c2, c3}, {d1, d2, d3}), do: {c1 - d1, c2 - d2, c3 - d3}

  @spec clamp({float(), float(), float()}) :: C.col3f()
  defp clamp({c1, c2, c3}) when is_float(c1) and is_float(c2) and is_float(c3) do
    {Math.unit(c1), Math.unit(c2), Math.unit(c3)}
  end
end
