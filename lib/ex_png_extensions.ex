defmodule ExPngExtensions do

  def line(image, coordinates0, coordinates1, color) do
    {x0, y0} = coordinates0
    {x1, y1} = coordinates1

    dx = x1 - x0
    dy = y1 - y0

    drawing_func =
      case {abs(dx), abs(dy)} do
        {_, 0} -> &ExPng.Image.line/4
        {0, _} -> &ExPng.Image.line/4
        {d, d} -> &ExPng.Image.line/4
        _ -> &draw_line/4
      end

    drawing_func.(image, coordinates0, coordinates1, color)
  end



  # This is a conversion of the ruby library ChunkyPng's circle function
  # because ExPng does not support drawing circles.
  # Taken from: https://github.com/wvanbergen/chunky_png/blob/7a1faf62f10b12ad3170d563b998db7893eda845/lib/chunky_png/canvas/drawing.rb#L106 
  def circle(img, x0, y0, radius, stroke_color) do
    f = 1 - radius
    dd_f_x = 1
    dd_f_y = -2 * radius
    x = 0
    y = radius

    img = ExPng.Image.draw(img, {x0, y0 + radius}, stroke_color)
    |> ExPng.Image.draw({x0, y0 - radius}, stroke_color)
    |> ExPng.Image.draw({x0 + radius, y0}, stroke_color)
    |> ExPng.Image.draw({x0 - radius, y0}, stroke_color)

    lines = [radius - 1]
    loop_circle(img, lines, f, dd_f_x, dd_f_y, x0, x, y0, y, stroke_color)
  end

  defp loop_circle(img, lines, f, dd_f_x, dd_f_y, x0, x, y0, y, stroke_color) when x < y do
    {y, dd_f_y, f} = if f >= 0 do
      {y - 1, dd_f_y + 2, f + dd_f_y + 2}
    else
      {y, dd_f_y, f}
    end 

    x = x + 1
    dd_f_x = dd_f_x + 2
    f = f + dd_f_x

    line_y = case Enum.at(lines, y) do
      nil -> x - 1
      value -> Enum.min([value, x - 1])
    end
    line_x = case Enum.at(lines, x) do
      nil -> y - 1
      value -> Enum.min([value, y - 1])
    end

    lines = List.replace_at(lines, y, line_y)
    |> List.replace_at(x, line_x)

    img = ExPng.Image.draw(img, {x0 + x,  y0 + y}, stroke_color)
    |> ExPng.Image.draw({x0 - x, y0 + y}, stroke_color)
    |> ExPng.Image.draw({x0 + x, y0 - y}, stroke_color)
    |> ExPng.Image.draw({x0 - x, y0 - y}, stroke_color)

    img = unless x == y do
      ExPng.Image.draw(img, {x0 + y,  y0 + x}, stroke_color)
      |> ExPng.Image.draw({x0 - y, y0 + x}, stroke_color)
      |> ExPng.Image.draw({x0 + y, y0 - x}, stroke_color)
      |> ExPng.Image.draw({x0 - y, y0 - x}, stroke_color)
    else
      img
    end

    img = Enum.with_index(lines)
    |> Enum.reduce(img, fn {len, y_offset}, acc ->
        acc = if len > 0 do
          ExPng.Image.line(acc, {x0 - len, y0 - y_offset}, {x0 + len, y0 - y_offset}, stroke_color)
        else
          acc
        end
        acc = if len > 0 && y_offset > 0 do
          ExPng.Image.line(acc, {x0 - len, y0 - y_offset}, {x0 + len, y0 - y_offset}, stroke_color)
        else
          acc
        end

        acc
      end)
    loop_circle(img, lines, f, dd_f_x, dd_f_y, x0, x, y0, y, stroke_color)
  end
  defp loop_circle(img, _lines, _f, _dd_f_x, _dd_f_y, _x0, _x, _y0, _y, _stroke_color) do
    img
  end

  defp draw_line(image, {x0, y0}, {x1, y1}, color) do
    draw_line(image, x0, y0, x1, y1, color) 
  end
  defp draw_line(image, x0, y0, x1, y1, color) do
    steep = abs(y1 - y0) > abs(x1 - x0)

    [x0, y0, x1, y1] =
      case steep do
        true -> [y0, x0, y1, x1]
        false -> [x0, y0, x1, y1]
      end

    [x0, y0, x1, y1] =
      case x0 > x1 do
        true -> [x1, y1, x0, y0]
        false -> [x0, y0, x1, y1]
      end

    dx = x1 - x0
    dy = y1 - y0
    gradient = 1.0 * dy / dx

    {image, xpxl1, yend} = draw_end_point(image, x0, y0, gradient, steep, color)
    itery = yend + gradient

    {image, xpxl2, _} = draw_end_point(image, x1, y1, gradient, steep, color)

    {_, image} =
      Enum.reduce((xpxl1 + 1)..(xpxl2 - 1), {itery, image}, fn x, {itery, image} ->
        image =
          image
          |> put_color(x, ipart(itery), color, steep, rfpart(itery))
          |> put_color(x, ipart(itery) + 1, color, steep, fpart(itery))

        {itery + gradient, image}
      end)

    image
  end

  defp draw_end_point(image, x, y, gradient, steep, color) do
    xend = round(x)
    yend = y + gradient * (xend - x)
    xgap = rfpart(x + 0.5)
    xpxl = xend
    ypxl = ipart(yend)

    image =
      image
      |> put_color(xpxl, ypxl, color, steep, rfpart(yend) * xgap)
      |> put_color(xpxl, ypxl + 1, color, steep, fpart(yend) * xgap)

    {image, xpxl, yend}
  end

  defp put_color(image, x, y, color, steep, c) do
    [x, y] = if steep, do: [y, x], else: [x, y]
    ExPng.Image.draw(image, {round(x), round(y)}, anti_alias(color, ExPng.Image.at(image, {round(x), round(y)}), c))
  end

  defp anti_alias(color, old, _ratio) when old == nil do
    color
  end
  defp anti_alias(color, old, ratio) do
    <<r, g, b, _>> = color
    <<old_r, old_g, old_b, _>> = old

    [r, g, b] =
      [r, g, b]
      |> Enum.zip([old_r, old_g, old_b])
      |> Enum.map(fn {n, o} -> round(n * ratio + o * (1.0 - ratio)) end)

    ExPng.Color.rgb(r, g, b)
  end

  defp ipart(x), do: Float.floor(x)
  defp fpart(x), do: x - ipart(x)
  defp rfpart(x), do: 1.0 - fpart(x)
end
