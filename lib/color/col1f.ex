defmodule Exa.Color.Col1f do
  @moduledoc "A 1-component floating-point grayscale or alpha."

  use Exa.Constants

  import Exa.Types
  alias Exa.Types, as: E

  import Exa.Color.Types
  alias Exa.Color.Types, as: C

  alias Exa.Math
  alias Exa.Convert

  alias Exa.Color.Col3b
  alias Exa.Color.Col1b
  alias Exa.Color.Col3f

  # ---------
  # constants
  # ---------

  @spec black() :: C.col1f()
  def black(), do: 0.0

  @spec white() :: C.col1f()
  def white(), do: 1.0

  @spec gray() :: C.col1f()
  def gray(), do: 0.5

  @doc "Gray level as a percentage 0..100"
  @spec gray_pc(E.percent()) :: C.col1f()
  def gray_pc(pc) when is_pc(pc), do: Math.unit(pc / 100.0)

  # -----------
  # constructor
  # -----------

  @doc "Create a new float color by clamping a float to unit range."
  @spec new(float()) :: C.col1f()
  def new(col) when is_float(col), do: Math.unit(col)

  # --------------
  # public methods
  # --------------

  @doc "Compare 1-component float colors for equality (within tolerance)."
  @spec equals?(C.col1f(), C.col1f(), E.epsilon()) :: bool()
  def equals?(c1, c2, eps \\ @epsilon) when is_col1f(c1) and is_col1f(c2) do
    Math.equals?(c1, c2, eps)
  end

  # modify ----------

  @doc "Reduce value."
  @spec dark(C.col1f()) :: C.col1f()
  def dark(col) when is_col1f(col), do: 0.5 * col

  @doc "Increase saturation."
  @spec pale(C.col1f()) :: C.col1f()
  def pale(col) when is_col1f(col), do: 0.5 * (1.0 + col)

  # conversion ----------

  @spec to_col3f(C.col1f()) :: C.col3f()
  def to_col3f(col) when is_col1f(col), do: Col3f.gray(col)

  @spec to_col1b(C.col1f()) :: C.col1b()
  def to_col1b(col) when is_col1f(col), do: Convert.f2b(col)

  @spec to_col3b(C.col1f()) :: C.col3b()
  def to_col3b(col) when is_col1f(col), do: col |> Convert.f2b() |> Col3b.gray()

  # blend ----------

  @doc """
  Linear interpolation between two colors.
  The parameter _x_ is a value between 0.0 (color1) and 1.0 (color2).
  """
  @spec lerp(C.col1f(), E.unit(), C.col1f()) :: C.col1f()
  def lerp(col1, x, col2) when is_col1f(col1) and is_col1f(col2) and is_unit(x) do
    Math.lerp(col1, x, col2)
  end

  @doc """
  A blend of a list of colors (optionally weighted).

  If the list is just colors, then the result is divided by the number of colors.

  If the list is weighted, the sum of weights should equal 1.0 (not enforced).
  The final color values are clamped to be in the range (0.0,1.0).
  """
  @spec blend(C.color_weights() | C.colors1()) :: C.col1f()

  def blend(wcols) when is_wcols(wcols) do
    wcols
    |> Enum.reduce(black(), fn
      {w, col}, sum when is_float(w) and is_col1f(col) -> sum + w * col
      {w, col}, sum when is_float(w) and is_col1b(col) -> sum + w * Col1b.to_col1f(col)
    end)
    |> Math.unit()
  end

  def blend(cols) when is_colors1(cols) do
    Enum.reduce(cols, black(), fn
      col, sum when is_col1f(col) -> sum + col
      col, sum when is_col1b(col) -> sum + Col1b.to_col1f(col)
    end) /
      length(cols)
  end
end
