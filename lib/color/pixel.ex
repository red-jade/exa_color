defmodule Exa.Color.Pixel do
  @moduledoc """
  Utilities for pixels.
  A pixel is a description of components in a color.
  """
  require Logger

  import Exa.Types
  alias Exa.Types, as: E

  import Exa.Color.Types
  alias Exa.Color.Types, as: C

  alias Exa.Math

  alias Exa.Color.Col1b
  alias Exa.Color.Col3b
  alias Exa.Color.Col4b

  alias Exa.Color.Col1f
  alias Exa.Color.Col3f
  alias Exa.Color.Col4f

  # ----------------
  # public functions
  # ----------------

  @doc "Get the number of components in a pixel or a color."
  @spec ncomp(C.pixel() | C.color()) :: C.ncomp()

  def ncomp(:gray), do: 1
  def ncomp(:index), do: 1

  def ncomp(:gray_alpha), do: 2
  def ncomp(:alpha_gray), do: 2

  def ncomp(:rgb), do: 3
  def ncomp(:bgr), do: 3

  def ncomp(:rgba), do: 4
  def ncomp(:bgra), do: 4
  def ncomp(:argb), do: 4
  def ncomp(:abgr), do: 4

  def ncomp(c) when is_number(c), do: 1
  def ncomp(c) when is_tuple(c) and is_number(elem(c, 0)), do: tuple_size(c)

  @doc "Get the 0-based component of a channel in a pixel."
  @spec comp(C.pixel(), C.channel()) :: C.ichan()

  def comp(:gray, :gray), do: 0
  def comp(:index, :index), do: 0

  def comp(:gray_alpha, :gray), do: 0
  def comp(:alpha_gray, :gray), do: 1
  def comp(:gray_alpha, :a), do: 1
  def comp(:alpha_gray, :a), do: 0

  def comp(:rgb, :r), do: 0
  def comp(:rgb, :g), do: 1
  def comp(:rgb, :b), do: 2

  def comp(:bgr, :b), do: 0
  def comp(:bgr, :g), do: 1
  def comp(:bgr, :r), do: 2

  def comp(:rgba, :r), do: 0
  def comp(:rgba, :g), do: 1
  def comp(:rgba, :b), do: 2
  def comp(:rgba, :a), do: 3

  def comp(:bgra, :b), do: 0
  def comp(:bgra, :g), do: 1
  def comp(:bgra, :r), do: 2
  def comp(:bgra, :a), do: 3

  def comp(:argb, :a), do: 0
  def comp(:argb, :r), do: 1
  def comp(:argb, :g), do: 2
  def comp(:argb, :b), do: 3

  def comp(:abgr, :a), do: 0
  def comp(:abgr, :b), do: 1
  def comp(:abgr, :g), do: 2
  def comp(:abgr, :r), do: 3

  @doc "Get the channel list for a pixel."
  @spec channels(C.pixel()) :: tuple()
  def channels(:gray), do: {:gray}
  def channels(:index), do: {:index}
  def channels(:alpha), do: {:a}
  def channels(:rgb), do: {:r, :g, :b}
  def channels(:bgr), do: {:b, :g, :r}
  def channels(:rgba), do: {:r, :g, :b, :a}
  def channels(:bgra), do: {:b, :g, :r, :a}
  def channels(:argb), do: {:a, :r, :g, :b}
  def channels(:abgr), do: {:a, :b, :g, :r}

  @doc "Test if a color format is compatible with a pixel type."
  @spec valid!(C.pixel(), C.color()) :: :ok
  def valid!(pix, col) do
    if ncomp(pix) != ncomp(col) do
      msg = "Color #{col} not compatible with pixel #{pix}"
      Logger.error(msg)
      raise ArgumentError, message: msg
    end
    :ok
  end

  # --------------
  # channel access 
  # --------------

  @spec component(C.color(), C.pixel(), C.channel()) :: C.component()
  def component(col, pix, chan), do: numtup(col, comp(pix, chan))

  # rgb always in tuples

  @spec r(C.color(), C.pixel()) :: C.component()
  def r(col, pix), do: elem(col, comp(pix, :r))

  @spec g(C.color(), C.pixel()) :: C.component()
  def g(col, pix), do: elem(col, comp(pix, :g))

  @spec b(C.color(), C.pixel()) :: C.component()
  def b(col, pix), do: elem(col, comp(pix, :b))

  # index is only available in index pixel
  # an index pixel is always a scalar (not a tuple)

  @spec index(C.color(), C.pixel()) :: C.component()
  def index(col, :index) when is_integer(col), do: col

  # gray can be scalar or tuple (gray alpha)
  # alpha can be scalar or tuple 

  @grays [:gray, :alpha_gray, :gray_alpha]

  @spec gray(C.color(), C.pixel()) :: C.component()
  def gray(col, pix) when pix in @grays, do: numtup(col, comp(pix, :gray))

  @alphas [:alpha_gray, :gray_alpha, :rgba, :argb, :bgra, :abgr]

  @spec a(C.color(), C.pixel()) :: C.component()
  def a(col, pix) when pix in @alphas, do: numtup(col, comp(pix, :a))

  # access a scalar or tuple pixel
  @spec numtup(number() | tuple(), E.index0()) :: number()
  defp numtup(col, i) when is_tuple(col) and i >= 0 and i < tuple_size(col), do: elem(col, i)
  defp numtup(col, 0) when is_number(col), do: col

  # ----------------
  # add/remove alpha
  # ----------------

  @doc """
  Get the alpha value from a color.

  The alpha component can be unit float or byte.
  If the color is 2-component or 4-component 
  then the actual alpha value is returned.
  If the color is a grayscale (1-component) or RGB (3-component)
  then the alpha defaults to 1.0.
  """
  @spec get_alpha(C.color(), C.pixel()) :: E.unit()
  def get_alpha(gray, :gray) when is_unit(gray), do: 1.0
  def get_alpha(gray, :gray) when is_byte(gray), do: 255
  def get_alpha({_gray, a}, :gray_alpha), do: a
  def get_alpha({a, _gray}, :alpha_gray), do: a
  def get_alpha({r, _g, _b}, :rgb) when is_unit(r), do: 1.0
  def get_alpha({r, _g, _b}, :rgb) when is_byte(r), do: 255
  def get_alpha({b, _g, _r}, :bgr) when is_unit(b), do: 1.0
  def get_alpha({b, _g, _r}, :bgr) when is_byte(b), do: 255
  def get_alpha({_r, _g, _b, a}, :rgba), do: a
  def get_alpha({a, _r, _g, _b}, :argb), do: a
  def get_alpha({_b, _g, _r, a}, :bgra), do: a
  def get_alpha({a, _b, _g, _r}, :abgr), do: a

  @doc """
  Remove the alpha value to create an opaque color.
  The given pixel shape is the original src pixel shape.
  The final color will have the same order of color components.
  The components can be floats or bytes.

  The alpha is not replaced, it is removed.
  An 4-component color will become 3-component.
  A 2-component color will become 1-component (scalar).
  """
  @spec del_alpha(C.color(), C.pixel()) :: C.color()
  def del_alpha(gray, :gray), do: gray
  def del_alpha(col, :rgb), do: col
  def del_alpha(col, :bgr), do: col
  def del_alpha({gray, _a}, :gray_alpha), do: gray
  def del_alpha({_a, gray}, :alpha_gray), do: gray
  def del_alpha({r, g, b, _a}, :rgba), do: {r, g, b}
  def del_alpha({_a, r, g, b}, :argb), do: {r, g, b}
  def del_alpha({b, g, r, _a}, :bgra), do: {b, g, r}
  def del_alpha({_a, b, g, r}, :abgr), do: {b, g, r}

  @doc """
  Add an alpha value to create an expanded color.
  The given pixel shape is the final dst pixel shape.
  The input color is assumed to have the 
  same order of color components as the result.

  The components can be floats or bytes.
  The color values and the alpha value must have the same type.

  The alpha is an added component (default 1.0 or 255).
  An 3-component color will become 4-component.
  A 1-component color (scalar) will become 2-component.
  """
  @spec add_alpha(C.color(), C.component(), C.pixel()) :: C.color()
  def add_alpha(gray, a, :gray_alpha) when is_byte(a) and is_byte(gray), do: {gray, a}
  def add_alpha(gray, a, :gray_alpha) when is_unit(a) and is_unit(gray), do: {gray, a}
  def add_alpha(gray, a, :alpha_gray) when is_byte(a) and is_byte(gray), do: {a, gray}
  def add_alpha(gray, a, :alpha_gray) when is_unit(a) and is_unit(gray), do: {a, gray}
  def add_alpha({r, g, b} = c, a, :rgba) when is_byte(a) and is_col3b(c), do: {r, g, b, a}
  def add_alpha({r, g, b} = c, a, :rgba) when is_unit(a) and is_col3f(c), do: {r, g, b, a}
  def add_alpha({r, g, b} = c, a, :argb) when is_byte(a) and is_col3b(c), do: {a, r, g, b}
  def add_alpha({r, g, b} = c, a, :argb) when is_unit(a) and is_col3f(c), do: {a, r, g, b}
  def add_alpha({b, g, r} = c, a, :bgra) when is_byte(a) and is_col3b(c), do: {b, g, r, a}
  def add_alpha({b, g, r} = c, a, :bgra) when is_unit(a) and is_col3f(c), do: {b, g, r, a}
  def add_alpha({b, g, r} = c, a, :abgr) when is_byte(a) and is_col3b(c), do: {a, b, g, r}
  def add_alpha({b, g, r} = c, a, :abgr) when is_unit(a) and is_col3f(c), do: {a, b, g, r}

  # -----------------
  # format conversion
  # -----------------

  @doc "Convert any color to float format."
  @spec to_colorf(C.color()) :: C.colorf()
  def to_colorf(c) when is_col1b(c), do: Col1b.to_col1f(c)
  def to_colorf(c) when is_col1f(c), do: c
  def to_colorf(c) when is_col3b(c), do: Col3b.to_col3f(c)
  def to_colorf(c) when is_col3f(c), do: c
  def to_colorf(c) when is_col4b(c), do: Col4b.to_col4f(c)
  def to_colorf(c) when is_col4f(c), do: c

  @doc "Convert any color to byte format."
  @spec to_colorb(C.color()) :: C.colorb()
  def to_colorb(c) when is_col1f(c), do: Col1f.to_col1b(c)
  def to_colorb(c) when is_col1b(c), do: c
  def to_colorb(c) when is_col3f(c), do: Col3f.to_col3b(c)
  def to_colorb(c) when is_col3b(c), do: c
  def to_colorb(c) when is_col4f(c), do: Col4f.to_col4b(c)
  def to_colorb(c) when is_col4b(c), do: c

  # -----------
  # max and min
  # -----------

  @doc "Minimum component value of a color."
  @spec minimum(C.color()) :: C.component()
  def minimum(col) when is_tuple(col), do: Exa.Tuple.min(col)

  @doc "Maximum component value of a color."
  @spec maximum(C.color()) :: C.component()
  def maximum(col) when is_tuple(col), do: Exa.Tuple.max(col)

  @doc """
  Maximum of a color. 
  Result is the max value and the channel label that is maximum.
  """
  @spec maximum(C.color(), C.pixel()) :: {C.component(), C.channel()}
  def maximum(col, pix) when is_tuple(col) do
    col |> Exa.Tuple.zip(channels(pix)) |> Enum.max()
  end

  @doc """
  Minimum of a color. 
  Result is the min value and the channel label that is minimum.
  """
  @spec minimum(C.color(), C.pixel()) :: {C.component(), C.channel()}
  def minimum(col, pix) when is_tuple(col) do
    col |> Exa.Tuple.zip(channels(pix)) |> Enum.min()
  end

  @doc "Component-wise minimum of two colors."
  @spec minimum2(C.color(), C.color()) :: C.color()

  def minimum2(c1, c2) when is_tuple(c1) and is_tuple(c2) and tuple_size(c1) == tuple_size(c2) do
    Enum.map(0..(tuple_size(c1) - 1), fn i -> min(elem(c1, i), elem(c2, i)) end)
  end

  def minimum2(c1, c2) when is_float(c1) and is_float(c2) do
    min(c1, c2)
  end

  def minimum2(c1, c2) when is_byte(c1) and is_byte(c2) do
    min(c1, c2)
  end

  @doc "Component-wise maximum of two colors."
  @spec maximum2(C.color(), C.color()) :: C.color()

  def maximum2(c1, c2) when is_tuple(c1) and is_tuple(c2) and tuple_size(c1) == tuple_size(c2) do
    Enum.map(0..(tuple_size(c1) - 1), fn i -> max(elem(c1, i), elem(c2, i)) end)
  end

  def maximum2(c1, c2) when is_float(c1) and is_float(c2) do
    max(c1, c2)
  end

  def maximum2(c1, c2) when is_byte(c1) and is_byte(c2) do
    max(c1, c2)
  end

  # ---------------
  # pixel functions
  # ---------------

  # TODO - allow functions that take multiple kinds of input pixels
  #        for example, any float-component pixel

  # TODO - allow standalone functions, implying nil-nil pixel types

  @doc """
  Compile a list of pixel functions into a single function.

  The initial implementation is just a linear pipeline of arity 1 functions.
  """
  def compile([{first_src, _, _} | _] = pixfuns) do
    {funs, last_pix} =
      Enum.reduce(pixfuns, {[], first_src}, fn {src, fun, dst}, {funs, prev} ->
        true = is_function(fun, 1)
        ^prev = src
        dst = if is_nil(dst), do: src, else: dst
        {[fun | funs], dst}
      end)

    funs = Enum.reverse(funs)

    compiled = fn p -> Enum.reduce(funs, p, fn f, p -> f.(p) end) end

    {first_src, compiled, last_pix}
  end

  # --------------
  # alpha blending
  # --------------

  @doc """
  Source color is the incoming foreground fragment.
  Destination color is the existing background fragment.

  The src, dst must be 3- or 4-component byte colors.
  Any 3-component color has implied alpha of 1.0 (solid, opaque).
  The output will be a byte color.

  The RGB order of src, dst and const blend color must be the same.

  Constant blend color should be Col3f.
  Constant blend alpha should be Col1f (float).

  The result is the same size and format as `dst_col` with `dst_pix`
  """
  @spec alpha_blend(C.color(), C.pixel(), C.color(), C.pixel(), C.blend_mode()) :: C.color()
  def alpha_blend(
        src_col,
        src_pix,
        dst_col,
        dst_pix,
        {func_rgb, func_a, param_rgb_src, param_rgb_dst, const_rgb, param_a_src, param_a_dst,
         const_a}
      )
      when is_colorb(src_col) and is_colorb(dst_col) do
    # TODO - many optimizations possible here ...
    # (1) Only one param_rgb_src or param_rgb_dst can reference the constant blend color?
    #     The constRGB should be pre-subtracted if param is `:one_minus_const_color`.
    # (2) Only one param_a_src or param_a_dst can reference the constant blend alpha.
    #     The const_a should be pre-subtracted if param is `:one_minus_const_alpha`.
    # (3) Change the functions to return functions with all conditionals removed,
    #     then apply the function at runtime.
    # (4) Factor out constant params that are independent of image data
    #     then use these across a whole image

    # separate the color-alpha for src and dst
    # convert to unit floats
    # default alpha is 1.0
    srgb = src_col |> del_alpha(src_pix) |> to_colorf()
    drgb = dst_col |> del_alpha(dst_pix) |> to_colorf()
    sa = src_col |> get_alpha(src_pix) |> to_colorf()
    da = dst_col |> get_alpha(dst_pix) |> to_colorf()

    col =
      case func_rgb do
        :func_min ->
          minimum2(srgb, drgb)

        :func_max ->
          maximum2(srgb, drgb)

        _ ->
          xsrgb = cparam(param_rgb_src, srgb, sa, drgb, da, const_rgb, const_a)
          xdrgb = cparam(param_rgb_dst, srgb, sa, drgb, da, const_rgb, const_a)
          func_rgb |> do_col(mul(xsrgb, srgb), mul(xdrgb, drgb)) |> Col3f.clamp()
      end

    case ncomp(dst_pix) do
      3 ->
        col |> to_colorb()

      4 ->
        a =
          case func_a do
            :func_min ->
              minimum2(sa, da)

            :func_max ->
              maximum2(sa, da)

            _ ->
              xsa = aparam(param_a_src, sa, da, const_a)
              xda = aparam(param_a_dst, sa, da, const_a)
              func_a |> do_alpha(mul(xsa, sa), mul(xda, da)) |> Math.unit()
          end

        col |> add_alpha(a, dst_pix) |> to_colorb()
    end
  end

  @spec cparam(C.blend_param(), E.unit(), E.unit(), E.unit(), E.unit(), E.unit(), E.unit()) ::
          :zero | :one | C.col3f()
  defp cparam(:zero, _, _, _, _, _, _), do: :zero
  defp cparam(:one, _, _, _, _, _, _), do: :one
  defp cparam(:src_color, src, _, _, _, _, _), do: src
  defp cparam(:dst_color, _, _, dst, _, _, _), do: dst
  defp cparam(:const_color, _, _, _, _, con, _), do: con
  defp cparam(:one_minus_src_color, src, _, _, _, _, _), do: Exa.Tuple.map(src, &one_minus/1)
  defp cparam(:one_minus_dst_color, _, dst, _, _, _, _), do: Exa.Tuple.map(dst, &one_minus/1)
  defp cparam(:one_minus_const_color, _, _, _, _, con, _), do: Exa.Tuple.map(con, &one_minus/1)
  defp cparam(:src_alpha, _, sa, _, _, _, _), do: Col3f.gray(sa)
  defp cparam(:dst_alpha, _, _, _, da, _, _), do: Col3f.gray(da)
  defp cparam(:const_alpha, _, _, _, _, _, ca), do: Col3f.gray(ca)
  defp cparam(:one_minus_src_alpha, _, sa, _, _, _, _), do: Col3f.gray(one_minus(sa))
  defp cparam(:one_minus_dst_alpha, _, _, _, da, _, _), do: Col3f.gray(one_minus(da))
  defp cparam(:one_minus_const_alpha, _, _, _, _, _, ca), do: Col3f.gray(one_minus(ca))

  @spec aparam(C.blend_param(), E.unit(), E.unit(), E.unit()) :: :zero | :one | E.unit()
  defp aparam(:zero, _, _, _), do: :zero
  defp aparam(:one, _, _, _), do: :one
  defp aparam(:src_color, sa, _, _), do: sa
  defp aparam(:dst_color, _, da, _), do: da
  defp aparam(:const_color, _, _, ca), do: ca
  defp aparam(:one_minus_src_color, sa, _, _), do: one_minus(sa)
  defp aparam(:one_minus_dst_color, _, da, _), do: one_minus(da)
  defp aparam(:one_minus_const_color, _, _, ca), do: one_minus(ca)
  defp aparam(:src_alpha, sa, _, _), do: sa
  defp aparam(:dst_alpha, _, da, _), do: da
  defp aparam(:const_alpha, _, _, ca), do: ca
  defp aparam(:one_minus_src_alpha, sa, _, _), do: one_minus(sa)
  defp aparam(:one_minus_dst_alpha, _, da, _), do: one_minus(da)
  defp aparam(:one_minus_const_alpha, _, _, ca), do: one_minus(ca)

  defp one_minus(x) when is_float(x), do: 1.0 - x

  @spec do_col(atom(), C.col3f(), C.col3f()) :: {float(), float(), float()}
  defp do_col(:func_add, srgb, drgb), do: add(srgb, drgb)
  defp do_col(:func_sub, srgb, drgb), do: sub(srgb, drgb)
  defp do_col(:func_rev_sub, srgb, drgb), do: sub(drgb, srgb)

  @spec do_col(atom(), C.col1f(), C.col1f()) :: float()
  defp do_alpha(:func_add, sa, da), do: add(sa, da)
  defp do_alpha(:func_sub, sa, da), do: sub(sa, da)
  defp do_alpha(:func_rev_sub, sa, da), do: sub(da, sa)

  # note the color components are not limited to unit range
  # values outside the range will be clamped
  @typep col() :: :zero | :one | float() | {float(), float(), float()}

  @spec mul(col(), col()) :: float() | {float(), float(), float()}
  defp mul(:zero, _), do: :zero
  defp mul(:one, d), do: d
  defp mul(d, :one), do: d
  defp mul({c1, c2, c3}, {d1, d2, d3}), do: {c1 * d1, c2 * d2, c3 * d3}
  defp mul(p, {d1, d2, d3}), do: {p * d1, p * d2, p * d3}
  defp mul(p, a), do: p * a

  @spec add(col(), col()) :: float() | {float(), float(), float()}
  defp add(:zero, c), do: c
  defp add(c, :zero), do: c
  defp add({c1, c2, c3}, {d1, d2, d3}), do: {c1 + d1, c2 + d2, c3 + d3}
  defp add(c, d), do: c + d

  @spec sub(col(), col()) :: float() | {float(), float(), float()}
  defp sub(c, :zero), do: c
  defp sub(:zero, {c1, c2, c3}), do: {-c1, -c2, -c3}
  defp sub(:zero, c), do: -c
  defp sub({c1, c2, c3}, {d1, d2, d3}), do: {c1 - d1, c2 - d2, c3 - d3}
  defp sub(c, d), do: c - d
end
