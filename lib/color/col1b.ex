defmodule Exa.Color.Col1b do
  @moduledoc """
  A 1-component byte color, 
  used for grayscale and indexed color.
  """
  import Exa.Types
  alias Exa.Types, as: E

  import Exa.Color.Types
  alias Exa.Color.Types, as: C

  alias Exa.Math
  alias Exa.Convert

  alias Exa.Color.Colorb
  alias Exa.Color.Col3b
  alias Exa.Color.Col3f

  # ---------
  # constants
  # ---------

  @spec black() :: C.col1b()
  def black(), do: 0

  @spec white() :: C.col1b()
  def white(), do: 255

  @spec gray() :: C.col1b()
  def gray(), do: 128

  @doc "Gray level as a percentage 0..100"
  @spec gray_pc(E.percent()) :: C.col1b()
  def gray_pc(pc) when is_pc(pc), do: Convert.f2b(pc / 100.0)

  # -----------
  # constructor
  # -----------

  @spec new(integer()) :: C.col1b()
  def new(i) when is_integer(i), do: clamp(i)

  # --------------
  # public methods
  # --------------

  # equals? use ==

  @doc "Reduce value."
  @spec dark(C.col1b()) :: C.col1b()
  def dark(col) when is_col1b(col), do: clamp(0.5 * col)

  @doc "Increase saturation."
  @spec pale(C.col1b()) :: C.col1b()
  def pale(col) when is_col1b(col), do: clamp(0.5 * (255 + col))

  @spec to_col1f(C.col1b()) :: C.col1f()
  def to_col1f(i) when is_col1b(i), do: Convert.b2f(i)

  @spec to_col3b(C.col1b()) :: C.col3b()
  def to_col3b(i) when is_col1b(i), do: Col3b.gray(i)

  @spec to_col3f(C.col1b()) :: C.col3f()
  def to_col3f(i) when is_col1b(i), do: i |> Convert.b2f() |> Col3f.gray()

  # no automatic from_col3b/f functions 
  # application should use to_gray and luma 

  # binary conversions ----------

  @c1 [:gray, :index]

  @behaviour Colorb

  @impl Colorb
  def to_bin(i, pix \\ :gray) when pix in @c1 and is_col1b(i), do: <<i>>

  @impl Colorb
  def append_bin(buf, pix \\ :gray, i) when pix in @c1 and is_binary(buf) and is_col1b(i),
    do: <<buf::binary, i>>

  @impl Colorb
  def from_bin(<<i, rest::binary>>, pix \\ :gray) when pix in @c1, do: {i, rest}

  # -----------------
  # private functions
  # -----------------

  # integers, or float versions of bytes 0.0-255.0 (not unit float component)
  @spec clamp(number()) :: C.col1b()
  defp clamp(i) when is_integer(i), do: Math.clamp_(0, i, 255)
  defp clamp(f) when is_float(f), do: Math.clamp_(0, trunc(f), 255)
end
