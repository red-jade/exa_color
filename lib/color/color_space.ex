defmodule Exa.Color.ColorSpace do
  @moduledoc "Conversions for color spaces."

  import Exa.Types

  import Exa.Color.Types
  alias Exa.Color.Types, as: C

  alias Exa.Math
  alias Exa.Color.Pixel

  @doc """
  Convert the format of an HSL color. 
  The input is the common CSS format of integer values:
  - H angle degrees 0-360 
  - S percent 0-100
  - L percent 0-100

  The output is a normalized unit color,
  with values in the range (0.0-1.0).
  """
  @spec hsl2unit(C.hsl3i()) :: C.col3f()
  def hsl2unit({h, s, l}) when is_integer(h) and is_integer(s) and is_integer(l) do
    {
      Math.clamp_(0, h, 360) / 360.0,
      Math.clamp_(0, s, 100) / 100.0,
      Math.clamp_(0, l, 100) / 100.0
    }
  end

  @doc """
  Convert the format of an HSL color. 

  The inputs are normalized unit color values (0.0-1.0).

  The output is a the common CSS format of integer values:
  - H angle degrees 0-360 
  - S percent 0-100
  - L percent 0-100
  """
  @spec unit2hsl(C.col3f()) :: C.hsl3i()
  def unit2hsl({h, s, l}) when is_unit(h) and is_unit(s) and is_unit(l) do
    {
      trunc(360.0 * Math.unit(h)),
      trunc(100.0 * Math.unit(s)),
      trunc(100.0 * Math.unit(l))
    }
  end

  @doc """
  RGB to HSL color model conversion.

  The result is a normalized unit 3-component color,
  not the common CSS format of:
  - H angle degrees 0-360 
  - S percent 0-100
  - L percent 0-100
  """
  @spec rgb2hsl(C.col3f()) :: C.col3f()
  def rgb2hsl({r, g, b} = c) when is_col3f(c) do
    {vmax, maxchan} = Pixel.maximum(c, :rgb)
    {vmin, _inchan} = Pixel.minimum(c, :rgb)
    d = vmax - vmin
    l = (vmax + vmin) / 2.0

    if d == 0.0 do
      # grayscale: set h = nil ?
      {0.0, 0.0, l}
    else
      s = if l < 0.5, do: d / (vmax + vmin), else: d / (2.0 - vmax - vmin)

      h =
        case maxchan do
          :r -> (g - b) / d + if(g < b, do: 6.0, else: 0.0)
          :g -> (b - r) / d + 2.0
          :b -> (r - g) / d + 4.0
        end

      {h / 6.0, s, l}
    end
  end

  @doc """
  HSL to RGB color model conversion.

  The input is a normalized unit 3-component color,
  with values in the range (0.0-1.0).
  """
  @spec hsl2rgb(C.col3f()) :: C.col3f()
  def hsl2rgb({h, s, l} = c) when is_col3f(c) do
    if s == 0.0 do
      {l, l, l}
    else
      q = if l < 0.5, do: l * (1.0 + s), else: l + s - l * s
      p = 2.0 * l - q
      r = h2rgb(p, q, h + 1 / 3)
      g = h2rgb(p, q, h)
      b = h2rgb(p, q, h - 1 / 3)
      {r, g, b}
    end
  end

  defp h2rgb(p, q, t) do
    t =
      cond do
        t < 0.0 -> t + 1.0
        t > 1.0 -> t - 1.0
        true -> t
      end

    cond do
      t < 1 / 6 -> p + (q - p) * 6.0 * t
      t < 3 / 6 -> q
      t < 4 / 6 -> p + (q - p) * (4 / 6 - t) * 6.0
      true -> p
    end
  end
end
