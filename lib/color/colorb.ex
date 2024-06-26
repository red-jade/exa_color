defmodule Exa.Color.Colorb do
  @moduledoc "A behaviour for byte colors."

  import Exa.Color.Types
  alias Exa.Color.Types, as: C

  alias Exa.Color.Col1b
  alias Exa.Color.Col3b
  alias Exa.Color.Col4b

  @doc "Convert a color to a binary."
  @callback to_bin(C.colorb(), C.pixel()) :: binary()

  @doc "Append a color to a binary."
  @callback append_bin(binary(), C.pixel(), C.colorb()) :: binary()

  @doc "Read a color from a binary."
  @callback from_bin(binary(), C.pixel()) :: {C.colorb(), binary()}

  # kinda like a protocol, but with tagged pixels instead of a struct...

  def from_bin(buf, :gray), do: Col1b.from_bin(buf, :gray)
  def from_bin(buf, :index), do: Col1b.from_bin(buf, :index)
  def from_bin(buf, :rgb), do: Col3b.from_bin(buf, :rgb)
  def from_bin(buf, :bgr), do: Col3b.from_bin(buf, :bgr)
  def from_bin(buf, :rgba), do: Col4b.from_bin(buf, :rgba)
  def from_bin(buf, :bgra), do: Col4b.from_bin(buf, :bgra)
  def from_bin(buf, :argb), do: Col4b.from_bin(buf, :argb)
  def from_bin(buf, :abgr), do: Col4b.from_bin(buf, :abgr)

  def append_bin(buf, :gray, col), do: Col1b.append_bin(buf, :gray, col)
  def append_bin(buf, :index, col), do: Col1b.append_bin(buf, :index, col)
  def append_bin(buf, :rgb, col), do: Col3b.append_bin(buf, :rgb, col)
  def append_bin(buf, :bgr, col), do: Col3b.append_bin(buf, :bgr, col)
  def append_bin(buf, :rgba, col), do: Col4b.append_bin(buf, :rgba, col)
  def append_bin(buf, :bgra, col), do: Col4b.append_bin(buf, :bgra, col)
  def append_bin(buf, :argb, col), do: Col4b.append_bin(buf, :argb, col)
  def append_bin(buf, :abgr, col), do: Col4b.append_bin(buf, :abgr, col)

  def to_bin(col, :gray) when is_col1b(col), do: Col1b.to_bin(col, :gray)
  def to_bin(col, :index) when is_col1b(col), do: Col1b.to_bin(col, :index)
  def to_bin(col, :rgb) when is_col3b(col), do: Col3b.to_bin(col, :rgb)
  def to_bin(col, :bgr) when is_col3b(col), do: Col3b.to_bin(col, :bgr)
  def to_bin(col, :argb) when is_col4b(col), do: Col4b.to_bin(col, :argb)
  def to_bin(col, :abgr) when is_col4b(col), do: Col4b.to_bin(col, :abgr)
  def to_bin(col, :rgba) when is_col4b(col), do: Col4b.to_bin(col, :rgba)
  def to_bin(col, :bgra) when is_col4b(col), do: Col4b.to_bin(col, :bgra)
end
