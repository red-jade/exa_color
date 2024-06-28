defmodule Exa.Color.Colorf do
  @moduledoc "A behaviour for float colors."

  import Exa.Color.Types
  alias Exa.Color.Types, as: C

  alias Exa.Color.Col1f
  alias Exa.Color.Col3f

  @doc """
  A mean blend of a list of colors (optionally weighted).

  Colors are always converted to floats for blending.

  If the list is just colors, then the sum is divided by the number of colors.

  If the list is weighted, the sum of weights should equal 1.0
  (or at least not exceed 1.0).

  The final color components will be clamped to the range (0.0,1.0),
  then converted to a byte color.

  The colors can only be 1- or 3-component.
  Colors with 2- or 4-components should use alpha blending to combine colors.
  """

  # @callback blend(C.color_weights() | C.colors3() | C.colors1()) :: C.col1b() | C.col3b()

  @spec blend(C.color_weights() | C.colors3() | C.colors1()) :: C.col1b() | C.col3b()

  def blend([{_, c} | _] = wcols) when is_color3(c) do
    wcols |> Col3f.blend() |> Col3f.to_col3b()
  end

  def blend([{_, c} | _] = wcols) when is_color1(c) do
    wcols |> Col1f.blend() |> Col1f.to_col1b()
  end
end
