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

  # get the 0-based component of a channel in a pixel
  @spec ichan(C.pixel(), C.channel()) :: C.ichan()

  defp ichan(:gray, :gray), do: 0
  defp ichan(:index, :index), do: 0

  defp ichan(:gray_alpha, :gray), do: 0
  defp ichan(:alpha_gray, :gray), do: 1
  defp ichan(:gray_alpha, :a), do: 1
  defp ichan(:alpha_gray, :a), do: 0

  defp ichan(:rgb, :r), do: 0
  defp ichan(:rgb, :g), do: 1
  defp ichan(:rgb, :b), do: 2

  defp ichan(:bgr, :b), do: 0
  defp ichan(:bgr, :g), do: 1
  defp ichan(:bgr, :r), do: 2

  defp ichan(:rgba, :r), do: 0
  defp ichan(:rgba, :g), do: 1
  defp ichan(:rgba, :b), do: 2
  defp ichan(:rgba, :a), do: 3

  defp ichan(:bgra, :b), do: 0
  defp ichan(:bgra, :g), do: 1
  defp ichan(:bgra, :r), do: 2
  defp ichan(:bgra, :a), do: 3

  defp ichan(:argb, :a), do: 0
  defp ichan(:argb, :r), do: 1
  defp ichan(:argb, :g), do: 2
  defp ichan(:argb, :b), do: 3

  defp ichan(:abgr, :a), do: 0
  defp ichan(:abgr, :b), do: 1
  defp ichan(:abgr, :g), do: 2
  defp ichan(:abgr, :r), do: 3

  # get the channel list for a pixel
  @spec channels(C.pixel()) :: tuple()
  defp channels(:gray), do: {:gray}
  defp channels(:index), do: {:index}
  defp channels(:alpha), do: {:a}
  defp channels(:rgb), do: {:r, :g, :b}
  defp channels(:bgr), do: {:b, :g, :r}
  defp channels(:rgba), do: {:r, :g, :b, :a}
  defp channels(:bgra), do: {:b, :g, :r, :a}
  defp channels(:argb), do: {:a, :r, :g, :b}
  defp channels(:abgr), do: {:a, :b, :g, :r}

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

  # ----------------
  # component access 
  # ----------------

  @grays [:gray, :alpha_gray, :gray_alpha]

  @alphas [:alpha_gray, :gray_alpha, :rgba, :argb, :bgra, :abgr]

  @rgbs [:rgb, :bgr, :rgba, :argb, :bgra, :abgr]

  @spec component(C.color(), C.pixel(), C.channel()) :: C.component()
  def component(col, pix, chan) do
    case ichan(pix, chan) do
      0 when is_number(col) -> col
      i when is_tuple(col) and i >= 0 and i < tuple_size(col) -> elem(col, i)
    end
  end

  # rgb always in tuples

  @spec r(C.color(), C.pixel()) :: C.component()
  def r(col, pix) when pix in @rgbs, do: component(col, pix, :r)

  @spec g(C.color(), C.pixel()) :: C.component()
  def g(col, pix) when pix in @rgbs, do: component(col, pix, :g)

  @spec b(C.color(), C.pixel()) :: C.component()
  def b(col, pix) when pix in @rgbs, do: component(col, pix, :b)

  # index is only available in index pixel
  # an index pixel is always a scalar (not a tuple)

  @spec index(C.col1b(), C.pixel()) :: C.component()
  def index(col, :index) when is_byte(col), do: col

  # gray and alpha can be scalar or tuple 

  @spec gray(C.color(), C.pixel()) :: C.component()
  def gray(col, pix) when pix in @grays, do: component(col, pix, :gray)

  @spec a(C.color(), C.pixel()) :: C.component()
  def a(col, pix) when pix in @alphas, do: component(col, pix, :a)

  # ----------------
  # add/remove alpha
  # ----------------

  # Get the float alpha value from a color.

  # The alpha component can be unit float or byte.

  # If the color is 2-component or 4-component 
  # then the actual alpha value is returned.

  # If the color is a grayscale (1-component) or RGB/BGR (3-component)
  # then the alpha defaults to 1.0.
  @spec get_alpha(C.color(), C.pixel()) :: C.col1f()
  defp get_alpha(col, pix) when pix in @alphas, do: col |> component(pix, :a) |> to_col1f()
  defp get_alpha(_, _), do: 1.0

  # Remove the alpha value to create an opaque color.

  # The given pixel shape is the original src pixel shape.
  # The final color will have the same order of color components.
  # The components can be floats or bytes.

  # The alpha is not replaced, it is removed.
  # An 4-component color will become 3-component.
  # A 2-component color will become 1-component (scalar).
  @spec del_alpha(C.color(), C.pixel()) :: C.col3f()
  # defp del_alpha(gray, :gray), do: to_col1f(gray)
  defp del_alpha(col, :rgb), do: to_col3f(col)
  defp del_alpha(col, :bgr), do: to_col3f(col)
  defp del_alpha({r, g, b, _a}, :rgba), do: to_col3f({r, g, b})
  defp del_alpha({_a, r, g, b}, :argb), do: to_col3f({r, g, b})
  defp del_alpha({b, g, r, _a}, :bgra), do: to_col3f({r, g, b})
  defp del_alpha({_a, b, g, r}, :abgr), do: to_col3f({r, g, b})
  # defp del_alpha({gray, _a}, :gray_alpha), do: to_col1f(gray)
  # defp del_alpha({_a, gray}, :alpha_gray), do: to_col1f(gray)

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

  # narrow version to keep dialyzer happy
  @spec to_col1f(C.col1b() | C.col1f()) :: C.col1f()
  defp to_col1f(c) when is_col1f(c), do: c
  defp to_col1f(c) when is_col1b(c), do: Col1b.to_col1f(c)

  # narrow version to keep dialyzer happy
  @spec to_col3f(C.col3b() | C.col3f()) :: C.col3f()
  defp to_col3f(c) when is_col3f(c), do: c
  defp to_col3f(c) when is_col3b(c), do: Col3b.to_col3f(c)

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
  @spec compile([C.pixel_fun(), ...]) :: C.pixel_fun()
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

  # note the color components are not limited to unit range
  # values outside the range will be clamped

  @typep col1() :: :zero | :one | float()

  @typep col3() :: :zero | :one | {float(), float(), float()}

  @typep pix34b() :: :rgb | :bgr | :rgba | :argb | :bgra | :abgr

  @typep col34b() :: C.col3b() | C.col4b()

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
  @spec alpha_blend(col34b(), pix34b(), col34b(), pix34b(), C.blend_mode()) :: col34b()
  def alpha_blend(
        src_col,
        src_pix,
        dst_col,
        dst_pix,
        {func_rgb, func_a, param_rgb_src, param_rgb_dst, const_rgb, param_a_src, param_a_dst,
         const_a}
      )
      when (is_col3b(src_col) or is_col4b(src_col)) and
             (is_col3b(src_col) or is_col4b(src_col)) do
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
    srgb = del_alpha(src_col, src_pix)
    drgb = del_alpha(dst_col, dst_pix)
    sa = get_alpha(src_col, src_pix)
    da = get_alpha(dst_col, dst_pix)

    col =
      case func_rgb do
        :func_min ->
          minimum2(srgb, drgb)

        :func_max ->
          maximum2(srgb, drgb)

        _ ->
          xsrgb = cparam(param_rgb_src, srgb, sa, drgb, da, const_rgb, const_a)
          xdrgb = cparam(param_rgb_dst, srgb, sa, drgb, da, const_rgb, const_a)
          do_col(func_rgb, mul3(xsrgb, srgb), mul3(xdrgb, drgb))
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
              do_alpha(func_a, mul1(xsa, sa), mul1(xda, da))
          end

        col |> add_alpha(a, dst_pix) |> to_colorb()
    end
  end

  @spec cparam(
          C.blend_param(),
          src_rgb :: C.col3f(),
          src_a :: C.col1f(),
          dst_rgb :: C.col3f(),
          dst_a :: C.col1f(),
          const_rgb :: nil | C.col3f(),
          const_a :: nil | C.col1f()
        ) :: col3()
  defp cparam(:zero, _, _, _, _, _, _), do: :zero
  defp cparam(:one, _, _, _, _, _, _), do: :one
  defp cparam(:src_color, src, _, _, _, _, _), do: src
  defp cparam(:dst_color, _, _, dst, _, _, _), do: dst
  defp cparam(:const_color, _, _, _, _, con, _), do: con
  defp cparam(:one_minus_src_color, src, _, _, _, _, _), do: Exa.Tuple.map(src, &one_minus/1)
  defp cparam(:one_minus_dst_color, _, _, dst, _, _, _), do: Exa.Tuple.map(dst, &one_minus/1)

  defp cparam(:one_minus_const_color, _, _, _, _, con, _) when not is_nil(con),
    do: Exa.Tuple.map(con, &one_minus/1)

  defp cparam(:src_alpha, _, sa, _, _, _, _), do: Col3f.gray(sa)
  defp cparam(:dst_alpha, _, _, _, da, _, _), do: Col3f.gray(da)
  defp cparam(:const_alpha, _, _, _, _, _, ca), do: Col3f.gray(ca)
  defp cparam(:one_minus_src_alpha, _, sa, _, _, _, _), do: Col3f.gray(one_minus(sa))
  defp cparam(:one_minus_dst_alpha, _, _, _, da, _, _), do: Col3f.gray(one_minus(da))

  defp cparam(:one_minus_const_alpha, _, _, _, _, _, ca) when not is_nil(ca),
    do: Col3f.gray(one_minus(ca))

  @spec aparam(C.blend_param(), C.col1f(), C.col1f(), nil | E.unit()) :: col1()
  defp aparam(:zero, _, _, _), do: :zero
  defp aparam(:one, _, _, _), do: :one
  defp aparam(:src_color, sa, _, _), do: sa
  defp aparam(:dst_color, _, da, _), do: da
  defp aparam(:const_color, _, _, ca) when not is_nil(ca), do: ca
  defp aparam(:one_minus_src_color, sa, _, _), do: one_minus(sa)
  defp aparam(:one_minus_dst_color, _, da, _), do: one_minus(da)
  defp aparam(:one_minus_const_color, _, _, ca) when not is_nil(ca), do: one_minus(ca)
  defp aparam(:src_alpha, sa, _, _), do: sa
  defp aparam(:dst_alpha, _, da, _), do: da
  defp aparam(:const_alpha, _, _, ca), do: ca
  defp aparam(:one_minus_src_alpha, sa, _, _), do: one_minus(sa)
  defp aparam(:one_minus_dst_alpha, _, da, _), do: one_minus(da)
  defp aparam(:one_minus_const_alpha, _, _, ca) when not is_nil(ca), do: one_minus(ca)

  defp one_minus(x) when is_float(x), do: 1.0 - x

  @spec do_col(atom(), :zero | C.col3f(), :zero | C.col3f()) :: C.col3f()
  defp do_col(:func_add, srgb, drgb), do: add3(srgb, drgb) |> reify3()
  defp do_col(:func_sub, srgb, drgb), do: sub3(srgb, drgb) |> reify3()
  defp do_col(:func_rev_sub, srgb, drgb), do: sub3(drgb, srgb) |> reify3()

  @spec do_alpha(atom(), :zero | C.col1f(), :zero | C.col1f()) :: C.col1f()
  defp do_alpha(:func_add, sa, da), do: add1(sa, da) |> reify1()
  defp do_alpha(:func_sub, sa, da), do: sub1(sa, da) |> reify1()
  defp do_alpha(:func_rev_sub, sa, da), do: sub1(da, sa) |> reify1()

  @spec reify1(:zero | C.col1f()) :: C.col1f()
  defp reify1(:zero), do: 0.0
  defp reify1(x) when is_float(x), do: Col1f.new(x)

  @spec reify3(:zero | C.col3f()) :: C.col3f()
  defp reify3(:zero), do: {0.0, 0.0, 0.0}
  defp reify3({r, g, b}), do: Col3f.new(r, g, b)

  @spec mul1(col1(), C.col1f()) :: :zero | C.col1f()
  defp mul1(:zero, _), do: :zero
  defp mul1(:one, d) when is_float(d), do: d
  defp mul1(c, d) when is_float(c) and is_float(d), do: c * d

  @spec mul3(col3(), C.col3f()) :: :zero | C.col3f()
  defp mul3(:zero, _), do: :zero
  defp mul3(:one, d) when is_col3f(d), do: d
  defp mul3({c1, c2, c3}, {d1, d2, d3}), do: {c1 * d1, c2 * d2, c3 * d3}

  @spec add1(:zero | C.col1f(), :zero | C.col1f()) :: C.col1f()
  defp add1(:zero, c), do: c
  defp add1(c, :zero), do: c
  defp add1(c, d) when is_float(c) and is_float(d), do: c + d

  @spec add3(:zero | C.col3f(), :zero | C.col3f()) :: C.col3f()
  defp add3(:zero, c) when is_tuple(c), do: c
  defp add3(c, :zero) when is_tuple(c), do: c
  defp add3({c1, c2, c3}, {d1, d2, d3}), do: {c1 + d1, c2 + d2, c3 + d3}

  @spec sub1(:zero | C.col1f(), :zero | C.col1f()) :: :zero | C.col1f()
  defp sub1(c, :zero), do: c
  defp sub1(:zero, c) when is_float(c), do: -c
  defp sub1(c, d) when is_float(c) and is_float(d), do: c - d

  @spec sub3(:zero | C.col3f(), :zero | C.col3f()) :: :zero | C.col3f()
  defp sub3(c, :zero), do: c
  defp sub3(:zero, {c1, c2, c3}), do: {-c1, -c2, -c3}
  defp sub3({c1, c2, c3}, {d1, d2, d3}), do: {c1 - d1, c2 - d2, c3 - d3}
end
