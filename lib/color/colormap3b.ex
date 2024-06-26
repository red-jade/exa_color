defmodule Exa.Color.Colormap3b do
  @moduledoc """
  A map of an integer index to a 3-byte RGB or 4-byte RGBA colors.
  """

  require Logger
  use Exa.Constants

  import Exa.Types
  alias Exa.Types, as: E

  import Exa.Color.Types
  alias Exa.Color.Types, as: C

  alias Exa.Convert

  alias Exa.Color.Col3f
  alias Exa.Color.ColorSpace

  # ---------
  # constants
  # ---------

  @spec dark_ramp(C.col3f()) :: C.colormap3b()
  def dark_ramp(col) when is_col3f(col), do: gradient(Col3f.black(), col, :rgb)

  @spec dark_red() :: C.colormap3b()
  def dark_red(), do: dark_ramp(Col3f.red())

  @spec dark_green() :: C.colormap3b()
  def dark_green(), do: dark_ramp(Col3f.green())

  @spec dark_blue() :: C.colormap3b()
  def dark_blue(), do: dark_ramp(Col3f.blue())

  @spec dark_magenta() :: C.colormap3b()
  def dark_magenta(), do: dark_ramp(Col3f.magenta())

  @spec sat_ramp(C.col3f()) :: C.colormap3b()
  def sat_ramp(col) when is_col3f(col), do: gradient(Col3f.white(), col, :rgb)

  @spec sat_red() :: C.colormap3b()
  def sat_red(), do: sat_ramp(Col3f.red())

  @spec sat_green() :: C.colormap3b()
  def sat_green(), do: sat_ramp(Col3f.green())

  @spec sat_blue() :: C.colormap3b()
  def sat_blue(), do: sat_ramp(Col3f.blue())

  @spec sat_magenta() :: C.colormap3b()
  def sat_magenta(), do: sat_ramp(Col3f.magenta())

  @spec blue_white_red() :: C.colormap3b()
  def blue_white_red(),
    do: gradient(Col3f.pale(Col3f.blue()), Col3f.white(), Col3f.pale(Col3f.red()), :rgb)

  # TODO - multiple stops for geo elevation map
  #        e.g. blue - desat blue / green - sat browns - dark browns - white 

  # ------------
  # constructors
  # ------------

  @doc """
  Build a colormap with a list of colors.

  The list of colors can be any size. 
  The colors will formed into a zero-based colormap,
  with a contiguous range of integers `0..(length(cols)-1)`.

  The pixel specifies the color format of the input colors.
  If the pixel is HSL, the colors are converted from HSL to RGB.
  The final colormap is always in RGB byte format.
  """
  @spec new([C.col3f()], :rgb | :hsl) :: C.colormap3b()
  def new(cols, pix \\ :rgb) when is_cols3f(cols) do
    imax = length(cols)

    {^imax, cmap} =
      Enum.reduce(cols, {0, %{}}, fn col, {i, cmap} ->
        {i + 1, Map.put(cmap, i, col)}
      end)

    {:colormap, :index, :rgb, convert(cmap, pix)}
  end

  @doc """
  Build a colormap with a linear gradient between two colors.

  The pixel gives the format of the color arguments 
  and hence the color space RGB/HSL for the linear interpolations.

  The final colormap is always in RGB format 
  (for 3-component color).
  """

  @spec gradient(C.col3f(), C.col3f(), C.pixel()) :: C.colormap3b()
  def gradient(c1, c2, pix) when is_col3f(c1) and is_col3f(c2) do
    gradient([{0, c1}, {255, c2}], pix)
  end

  @doc """
  Build a colormap with two linear gradients between three colors.
  The colors are assumned to be set at index values 0, 127 and 255.

  The pixel gives the format of the color arguments 
  and hence the color space RGB/HSL for the linear interpolations.

  The final colormap is always in RGB format 
  (for 3-component color).
  """

  @spec gradient(C.col3f(), C.col3f(), C.col3f(), C.pixel()) :: C.colormap3b()
  def gradient(c1, c2, c3, pix) when is_col3f(c1) and is_col3f(c2) do
    gradient([{0, c1}, {127, c2}, {255, c3}], pix)
  end

  @doc """
  Build a colormap with piecewise-linear gradients. 

  The argument is a list of `{index,color}` pairs.
  The list should be sorted in ascending order,
  with no duplication of indices.
  The first and last indicies should be 0 and 255
  (for 8-bit index).

  The pixel gives the format of the color arguments 
  and hence the color space RGB/HSL for the linear interpolations.

  The final colormap is always in RGB format 
  (for 3-component color).
  """
  @spec gradient([C.icol3f()], C.pixel()) :: C.colormap3b()
  def gradient([{0, _} = icol1 | icols], pix) when icols != [] do
    {{256, _}, cmap} =
      Enum.reduce(icols, {icol1, %{}}, fn {j, c2} = jcol, {{i, _} = icol, cmap} when j > i ->
        {{j + 1, c2}, linear(icol, jcol, cmap)}
      end)

    {:colormap, :index, :rgb, convert(cmap, pix)}
  end

  @doc """
  Validate a colormap. 

  Returns the maximum index of the 0-based colormap.

  The map should have a range of indices `0..max_index-1`.
  The check is O(nlogn), so should not be used in loops.
  """
  @spec validate!(C.colormap3b()) :: E.index0()
  def validate!({:colormap, :index, :rgb, cmap}) do
    imax = map_size(cmap) - 1
    ixs = cmap |> Map.keys() |> Enum.sort()

    if ixs != Range.to_list(0..imax) do
      msg = "Invalid index keys, expecting 0..#{imax}, found #{ixs}"
      Logger.error(msg)
      raise ArgumentError, message: msg
    end

    if imax > 255 do
      msg = "Colormap index exceeds 255, found #{imax}"
      Logger.error(msg)
      raise ArgumentError, message: msg
    end

    imax
  end

  # ---------
  # accessors
  # --------- 

  @doc """
  Look-up an index value in the colormap.

  Raises an error if the index is not in the colormap.
  """
  @spec lookup(C.colormap3b(), byte()) :: C.col3f()
  def lookup({:colormap, :index, _pix, cmap}, i) when is_byte(i), do: Map.fetch!(cmap, i)

  # --------------
  # public methods
  # --------------

  # ---------------
  # private methods
  # ---------------

  # TOCO - fix HSL interpolation
  #        when H should be nil (s == 0 or l == 0)
  #        then keep the other H fixed as s and l are interpolated

  # linear interpolation for two colors across an index sequence
  @spec linear(C.icol3f(), C.icol3f(), C.cmap3b()) :: C.cmap3b()

  defp linear({imin, c1}, {imax, c2}, cmap) when imax == imin + 1 do
    cmap |> Map.put(imin, c1) |> Map.put(imax, c2)
  end

  defp linear({0, c1}, {255, c2}, cmap) do
    Enum.reduce(0..255, cmap, fn i, cmap ->
      Map.put(cmap, i, Col3f.lerp(c1, Convert.b2f(i), c2))
    end)
  end

  defp linear({imin, c1}, {imax, c2}, cmap) when imax > imin + 1 do
    iscale = 1.0 / (imax - imin)

    Enum.reduce(imin..imax, cmap, fn i, cmap ->
      Map.put(cmap, i, Col3f.lerp(c1, (i - imin) * iscale, c2))
    end)
  end

  # convert colormap from HSL to RGB 3f to RGB 3b 
  @spec convert(C.cmap3b(), C.pixel()) :: C.cmap3b()

  defp convert(cmap, :rgb) do
    for({i, c} <- cmap, into: %{}, do: {i, Col3f.to_col3b(c)})
  end

  defp convert(cmap, :hsl) do
    for {i, c} <- cmap, into: %{} do
      {i, c |> ColorSpace.hsl2rgb() |> Col3f.to_col3b()}
    end
  end
end
