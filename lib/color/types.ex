defmodule Exa.Color.Types do
  @moduledoc "Types and guards for color utilities."

  import Exa.Types
  alias Exa.Types, as: E

  # ------
  # colors
  # ------

  # bytes

  @doc "A 1-component byte color: grayscale, index or alpha."
  @type col1b() :: byte()
  defguard is_col1b(c) when is_byte(c)

  @doc "A 3-component byte color: RGB, BGR."
  @type col3b() :: {byte(), byte(), byte()}
  defguard is_col3b(c)
           when is_fix_tuple(c, 3) and
                  is_byte(elem(c, 0)) and is_byte(elem(c, 1)) and is_byte(elem(c, 2))

  @doc "A 4-component byte color: RGBA, ARGB, BGRA, ABGR."
  @type col4b() :: {byte(), byte(), byte(), byte()}
  defguard is_col4b(c)
           when is_fix_tuple(c, 4) and
                  is_byte(elem(c, 0)) and is_byte(elem(c, 1)) and
                  is_byte(elem(c, 2)) and is_byte(elem(c, 3))

  # floats 

  @doc "A 1-component float color: grayscale or alpha."
  @type col1f() :: E.unit()
  defguard is_col1f(c) when is_unit(c)

  @doc "A 3-component float color: RGB or BGR."
  @type col3f() :: {E.unit(), E.unit(), E.unit()}
  defguard is_col3f(c)
           when is_fix_tuple(c, 3) and
                  is_unit(elem(c, 0)) and is_unit(elem(c, 1)) and is_unit(elem(c, 2))

  @doc "A list of 3-component float colors."
  @type cols3f() :: [col3f(), ...]
  defguard is_cols3f(cs) when is_list(cs) and cs != [] and is_col3f(hd(cs))

  @doc "A 4-component float color: RGBA, ARGB, BGRA, ABGR."
  @type col4f() :: {E.unit(), E.unit(), E.unit(), E.unit()}
  defguard is_col4f(c)
           when is_fix_tuple(c, 4) and
                  is_unit(elem(c, 0)) and is_unit(elem(c, 1)) and
                  is_unit(elem(c, 2)) and is_unit(elem(c, 3))

  @doc "A list of 4-component float colors."
  @type cols4f() :: [col4f(), ...]
  defguard is_cols4f(cs) when is_list(cs) and cs != [] and is_col4f(hd(cs))

  # generic 

  @typedoc "Any byte color."
  @type colorb() :: col1b() | col3b() | col4b()

  defguard is_colorb(c) when is_col1b(c) or is_col3b(c) or is_col4b(c)

  defguard is_colorb(c, n)
           when (n == 1 and is_col1b(c)) or (n == 3 and is_col3b(c)) or (n == 4 and is_col4b(c))

  @typedoc "Any float color."
  @type colorf() :: col1f() | col3f() | col4f()

  defguard is_colorf(c) when is_col1f(c) or is_col3f(c) or is_col4f(c)

  defguard is_colorf(c, n)
           when (n == 1 and is_col1b(c)) or (n == 3 and is_col3b(c)) or (n == 4 and is_col4b(c))

  @typedoc "Any color."
  @type color() :: colorb() | colorf()
  defguard is_color(c) when is_colorb(c) or is_colorf(c)
  defguard is_color(c, n) when is_colorb(c, n) or is_colorf(c, n)

  # component categories

  @typedoc "Any 1-component color: grayscale, index, alpha."
  @type color1() :: col1f() | col1b()
  defguard is_color1(c) when is_col1f(c) or is_col1b(c)

  @typedoc "A list of 1-component colors."
  @type colors1() :: [color1(), ...]
  defguard is_colors1(cs) when is_nonempty_list(cs) and is_color1(hd(cs))

  @typedoc "Any 3-component color: RGB or BGR."
  @type color3() :: col3f() | col3b()
  defguard is_color3(c) when is_col3f(c) or is_col3b(c)

  @typedoc "A list of 3-component colors."
  @type colors3() :: [color3(), ...]
  defguard is_colors3(cs) when is_nonempty_list(cs) and is_color3(hd(cs))

  @typedoc "Any 4-component color: RGBA, ARGB, BGRA, ABGR."
  @type color4() :: col4f() | col4b()
  defguard is_color4(c) when is_col4f(c) or is_col4b(c)

  @typedoc "A list of 4-component colors."
  @type colors4() :: [color4(), ...]
  defguard is_colors4(cs) when is_nonempty_list(cs) and is_color4(hd(cs))

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

  @typedoc "Named color has a name and a 3-byte RGB color."
  @type col3name() :: {String.t(), col3b()}
  defguard is_col3name(c)
           when is_fix_tuple(c, 2) and
                  is_string(elem(c, 0)) and is_col3b(elem(c, 1))

  # -----------
  # hex strings
  # -----------

  @typedoc "Text color format for 3-bytes as hexadecimal string."
  @type hex3() :: String.t()
  defguard is_hex3(h) when is_fix_string(h, 7) and binary_part(h, 0, 1) == "#"

  @typedoc "Text color format for 4-bytes as hexadecimal string."
  @type hex4() :: String.t()
  defguard is_hex4(h) when is_fix_string(h, 9) and binary_part(h, 0, 1) == "#"

  # ------
  # pixels
  # ------

  @typedoc "Color channel components."
  @type channel() :: :index | :gray | :a | :r | :g | :b | :h | :s | :l
  defguard is_chan(ch) when ch in [:index, :gray, :a, :r, :g, :b, :h, :s, :l]

  @typedoc "1-channel pixel formats."
  @type pixel1() :: :index | :gray | :alpha
  defguard is_pix1(px) when px in [:index, :gray, :alpha]

  @typedoc "2-channel pixel formats."
  @type pixel2() :: :gray_alpha | :alpha_gray
  defguard is_pix2(px) when px in [:gray_alpha, :alpha_gray]

  @typedoc "3-channel pixel formats."
  @type pixel3() :: :rgb | :bgr
  defguard is_pix3(px) when px in [:rgb, :bgr]

  @typedoc "4-channel pixel formats."
  @type pixel4() :: :rgba | :argb | :bgra | :abgr
  defguard is_pix4(px) when px in [:rgba, :argb, :bgra, :abgr]

  @typedoc "All pixel formats."
  @type pixel() :: pixel1() | pixel2() | pixel3() | pixel4()
  defguard is_pix(px) when is_pix1(px) or is_pix3(px) or is_pix4(px) or is_pix2(px)

  @typedoc "A component of a color: byte (0..255) or unit float (0.0-1.0)."
  @type component() :: byte() | E.unit()
  defguard is_comp(c) when is_byte(c) or is_unit(c)

  @typedoc "The number of components in a tuple."
  @type ncomp() :: 1..4
  defguard is_ncomp(n) when is_integer(n) and n > 0 and n < 5

  @typedoc "The 0-based index of a channel in a color."
  @type ichan() :: 0..3
  defguard is_ichan(i) when is_integer(i) and i >= 0 and i < 4

  @typedoc """
  An alpha input value for a byte may be:
  - boolean (false -> transparent 0, true -> opaque 255)
  - bit (0 -> transparent 0, 1 -> opaque 255)
  - byte 0..255
  - unit float 0.0-1.0, maps to 0..255
  """
  @type alpha_value() :: bool() | E.bit() | byte() | E.unit()

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

  @typedoc "A list of weighted colors."
  @type color_weights() :: [color_weight(), ...]
  defguard is_wcols(wcs) when is_nonempty_list(wcs) and is_wcol(hd(wcs))

  # -------------
  # pixel mappers
  # -------------

  @typedoc """
  A color-color mapping function.
  """
  @type colfun() :: (color() -> color())

  @typedoc """
  A pixel color-color mapping stage to transform an image.
  The input and output pixel types may be different.

  A `nil` source pixel means it defaults to 
  the pixel type of the input source image.

  A `nil` destination pixel means it defaults to
  the source pixel type.
  """
  @type pixel_fun() ::
          colfun()
          | {src :: E.maybe(pixel()), colfun(), dst :: E.maybe(pixel())}
  defguard is_pixfun(src, fun, dst)
           when (is_nil(src) or is_pix(src)) and
                  (is_nil(dst) or is_pix(dst)) and
                  is_function(fun, 1)

  # -----------
  # alpha blend
  # -----------

  # slow implementation of the OpenGL alpha blending function

  @type blend_func() :: :func_add | :func_sub | :func_rev_sub | :func_min | :func_max

  @type blend_param() ::
          :zero
          | :one
          | :src_color
          | :one_minus_src_color
          | :dst_color
          | :one_minus_dst_color
          | :const_color
          | :one_minus_const_color
          | :src_alpha
          | :one_minus_src_alpha
          | :dst_alpha
          | :one_minus_dst_alpha
          | :const_alpha
          | :one_minus_const_alpha

  # const_rgb   is only needed for :const_color, :one_minus_const_color
  # const_alpha is only needed for :const_alpha, :one_minus_const_alpha

  @type blend_mode() :: {
          func_rgb :: blend_func(),
          func_a :: blend_func(),
          param_rgb_src :: blend_param(),
          param_rgb_dst :: blend_param(),
          const_rgb :: nil | col3f(),
          param_a_src :: blend_param(),
          param_a_dst :: blend_param(),
          const_a :: nil | col1f()
        }

  # --------
  # colormap
  # --------

  @typedoc "A colormap to lookup a 1-byte grayscale for a byte index."
  @type cmap1b() :: %{byte() => col1b()}

  @typedoc "A colormap to lookup a 3-byte color for a byte index."
  @type cmap3b() :: %{byte() => col3b()}

  @typedoc "A colormap to lookup a 4-byte color for a byte index."
  @type cmap4b() :: %{byte() => col4b()}

  @typedoc "A full colormap with pixel types and 1-byte lookup table."
  @type colormap1b() :: {:colormap, :index, :gray, cmap1b()}

  @typedoc "A full colormap with pixel types and 3-byte lookup table."
  @type colormap3b() :: {:colormap, :index, :rgb, cmap3b()}

  @typedoc "A full colormap with pixel types and 4-byte lookup table."
  @type colormap4b() :: {:colormap, :index, :rgba, cmap4b()}

  @typedoc "Any 1,3,4-byte colormap."
  @type colormap() :: colormap1b() | colormap3b() | colormap4b()

  @typedoc "A control point to specify an indexed colormap gradient."
  @type icol3f() :: {byte(), col3f()}
end
