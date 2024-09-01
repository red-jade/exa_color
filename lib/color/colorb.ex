defmodule Exa.Color.Colorb do
  @moduledoc """
  A behaviour for byte colors,
  with a generic interface that dispatches 
  to concrete implementations.
  """

  alias Exa.Color.Types, as: C

  alias Exa.Color.Col1b
  alias Exa.Color.Col3b
  alias Exa.Color.Col4b

  # dispatch map from tags to implementation module
  @disp %{
  :gray => Col1b,
  :index => Col1b,
  :rgb => Col3b,
  :bgr => Col3b,
  :rgba => Col4b,
  :bgra => Col4b,
  :argb => Col4b,
  :abgr =>  Col4b,
  }

  # it's more natural to have the buffer as first arg for piping
  # but dispatching implementations must have the tag as 1st arg

  @doc "Convert a color to a binary."
  @callback to_bin(C.pixel(), C.colorb()) :: binary()

  @doc "Append a color to a binary."
  @callback append_bin(C.pixel(), binary(), C.colorb()) :: binary()

  @doc "Read a color from a binary."
  @callback from_bin(C.pixel(), binary()) :: {C.colorb(), binary()}

  def from_bin(pix, buf) do
    Exa.Dispatch.dispatch(@disp, pix, :from_bin, [buf])
  end

  def append_bin(pix, buf, col) do
    Exa.Dispatch.dispatch(@disp, pix, :append_bin, [buf, col])
  end

  def to_bin(pix, col) do
    Exa.Dispatch.dispatch(@disp, pix, :to_bin, [col])
  end
end
