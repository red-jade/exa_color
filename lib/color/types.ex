defmodule Exa.Color.Types do
  @moduledoc "Types and guards for the colors utilities."

  import Exa.Types
  alias Exa.Types, as: E

  # ------
  # colors
  # ------

  # bytes

  @type col1b() :: byte()
  defguard is_col1b(c) when is_byte(c)

  @type col3b() :: {byte(), byte(), byte()}
  defguard is_col3b(c)
           when is_fix_tuple(c, 3) and
                  is_byte(elem(c, 0)) and is_byte(elem(c, 1)) and is_byte(elem(c, 2))

  @type col4b() :: {byte(), byte(), byte(), byte()}
  defguard is_col4b(c)
           when is_fix_tuple(c, 4) and
                  is_byte(elem(c, 0)) and is_byte(elem(c, 1)) and
                  is_byte(elem(c, 2)) and is_byte(elem(c, 3))

  # floats 

  @type col1f() :: E.unit()
  defguard is_col1f(c) when is_unit(c)

  @type col3f() :: {E.unit(), E.unit(), E.unit()}
  defguard is_col3f(c)
           when is_fix_tuple(c, 3) and
                  is_unit(elem(c, 0)) and is_unit(elem(c, 1)) and is_unit(elem(c, 2))

  @type cols3f() :: [col3f(), ...]
  defguard is_cols3f(cs) when is_list(cs) and cs != [] and is_col3f(hd(cs))

  @type col4f() :: {E.unit(), E.unit(), E.unit(), E.unit()}
  defguard is_col4f(c)
           when is_fix_tuple(c, 4) and
                  is_unit(elem(c, 0)) and is_unit(elem(c, 1)) and
                  is_unit(elem(c, 2)) and is_unit(elem(c, 3))

  @type cols4f() :: [col4f(), ...]
  defguard is_cols4f(cs) when is_list(cs) and cs != [] and is_col4f(hd(cs))

  # generic 

  @typedoc "Any byte color."
  @type colorb() :: G.col1b() | G.col3b() | G.col4b()

  defguard is_colorb(c) when is_col1b(c) or is_col3b(c) or is_col4b(c)

  defguard is_colorb(c, n)
           when (n == 1 and is_col1b(c)) or (n == 3 and is_col3b(c)) or (n == 4 and is_col4b(c))

  @typedoc "Any float color."
  @type colorf() :: G.col1f() | G.col3f() | G.col4f()

  defguard is_colorf(c) when is_col1f(c) or is_col3f(c) or is_col4f(c)

  defguard is_colorf(c, n)
           when (n == 1 and is_col1b(c)) or (n == 3 and is_col3b(c)) or (n == 4 and is_col4b(c))

  @typedoc "Any color."
  @type color() :: colorb() | colorf()
  defguard is_color(c) when is_colorb(c) or is_colorf(c)
  defguard is_color(c, n) when is_colorb(c, n) or is_colorf(c, n)

  @typedoc "Any 3-component color."
  @type color3() :: col3f() | col3b()
  defguard is_color3(c) when is_col3f(c) or is_col3b(c)

  @type colors3() :: [color3(), ...]
  defguard is_colors3(cs) when is_nonempty_list(cs) and is_color3(hd(cs))

  @typedoc "Any 4-component color."
  @type color4() :: col4f() | col4b()
  defguard is_color4(c) when is_col4f(c) or is_col4b(c)

  @type colors4() :: [color4(), ...]
  defguard is_colors4(cs) when is_nonempty_list(cs) and is_color4(hd(cs))

  @typedoc "Any 1-component color."
  @type color1() :: col1f() | col1b()
  defguard is_color1(c) when is_col1f(c) or is_col1b(c)

  @type colors1() :: [color1(), ...]
  defguard is_colors1(cs) when is_nonempty_list(cs) and is_color1(hd(cs))
 
  # ------------
  # color models
  # ------------

  @typedoc """
  The CSS format of HSL integer values:
  - H angle degrees 0-360 
  - S percent 0-100
  - L percent 0-100
  """
  @type hsl3i() :: {0..360, 0..100, 0..100}

  # ------------
  # named colors
  # ------------

  @type col3name() :: {atom(), G.col3b()}
  defguard is_col3name(c)
           when is_fix_tuple(c, 2) and
                  is_atom(elem(c, 0)) and is_col3b(elem(c, 1))

  # ------
  # pixels
  # ------

  @typedoc "Color channel components."
  @type channel() :: :index | :gray | :a | :r | :g | :b | :h | :s | :l

  @typedoc "1-channel pixel formats."
  @type pixel1() :: :index | :gray | :alpha

  @typedoc "2-channel pixel formats."
  @type pixel2() :: :gray_alpha | :alpha_gray

  @typedoc "3-channel pixel formats."
  @type pixel3() :: :rgb | :bgr

  @typedoc "4-channel pixel formats."
  @type pixel4() :: :rgba | :argb | :bgra | :abgr

  @typedoc "All pixel formats."
  @type pixel() :: pixel1() | pixel2() | pixel3() | pixel4()
  defguard is_pix(px)
           when px in [
                  :gray,
                  :rgb,
                  :rgba,
                  :alpha,
                  :index,
                  :bgr,
                  :argb,
                  :abgr,
                  :bgra,
                  :gray_alpha,
                  :alpha_gray
                ]

  # ---------------
  # weighted blends
  # ---------------

  @typedoc "A multiplicative factor to scale a color."
  @type weight() :: float()
  defguard is_weight(w) when is_float(w)

  @typedoc "A scalar weighted color."
  @type color_weight() :: {weight(), color()}
  defguard is_wcol(wc)
           when is_fix_tuple(wc, 2) and
                  is_weight(elem(wc, 0)) and is_color(elem(wc, 1))

  @typedoc """
  A list of weighted colors.
  A color without a factor is assumed to have weight 1.0.
  """
  @type color_weights() :: [color_weight(), ...]
  defguard is_wcols(wcs) when is_nonempty_list(wcs) and is_wcol(hd(wcs))
end
