defmodule Exa.Color.Col3Name do
  @moduledoc """
  A 3-component RGB color name.
  RGB values are defined as bytes (Col3b).

  Values are taken from the _CSS Color Module Level 4_ candidate recommendation
  \[[html](https://www.w3.org/TR/css-color-4/)]
  """
  require Logger
  import Exa.Types

  alias Exa.Color.Col3b

  alias Exa.Color.Types, as: C

  @css_file Path.join(["priv", "css", "css-level4.txt"])

  # ----------------
  # public functions
  # ----------------

  @spec new(String.t()) :: C.col3name()
  def new(str) when is_string(str) do
    cmap = Exa.Process.get_or_set(:css_colors, &load_css/0)
    name = str |> String.replace(" ", "") |> String.downcase()

    case Map.fetch(cmap, name) do
      :error ->
        msg = "CSS color '#{str}' does not exist"
        Logger.error(msg)
        raise ArgumentError, message: msg

      {:ok, col} ->
        {name, col}
    end
  end

  @spec to_name(C.col3name()) :: String.t()
  def to_name({name, _}) when is_string(name), do: to_string(name)

  @spec to_col3b(C.col3name()) :: C.col3b()
  def to_col3b({_name, col3b}), do: col3b

  @spec to_col3f(C.col3name()) :: C.col3f()
  def to_col3f({_name, col3b}), do: Col3b.to_col3f(col3b)

  @spec to_hex(C.col3name()) :: C.hex3()
  def to_hex({_name, col3b}), do: Col3b.to_hex(col3b, :rgb)

  # -----------------
  # private functions
  # -----------------

  # read the text file definitions
  # load into the process dictionary

  @spec load_css() :: %{String.t() => C.col3b()}
  defp load_css() do
    @css_file 
    |> Exa.File.from_file_lines(comments: ["//"]) 
    |> Enum.map(fn line -> line |> String.split() |> List.to_tuple() end)
    |> Enum.reduce(%{}, fn {name, hex}, cmap -> Map.put(cmap, name, Col3b.from_hex(hex)) end)
  end

end
