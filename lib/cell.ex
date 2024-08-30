defmodule Cell do
  defstruct [:row, :col, :north, :south, :east, :west, :links, :weight]

  def initialize(row, column) do
    %Cell{row: row, col: column, links: %{}, weight: 1}
  end

  def link(cell, linked) do
    new_links = cell.links
    new_links = Map.put(new_links, {linked.row, linked.col}, true)
    %Cell{cell | links: new_links}
  end

  def unlink(cell, linked) do
    new_links = cell.links
    new_links = Map.delete(new_links, {linked.row, linked.col})
    %Cell{cell | links: new_links}
  end

  def links(cell) do
    Map.keys(cell.links)
  end

  def linked?(cell, other_cell) when is_tuple(other_cell) do
    Map.has_key?(cell.links, other_cell)
  end
  def linked?(%Cell3d{} = cell, %Cell3d{} = other_cell) do
    linked?(cell, Cell3d.get_location(other_cell))
  end
  def linked?(cell, other_cell) do
    case other_cell do
      nil -> false
      _ -> Map.has_key?(cell.links, {other_cell.row, other_cell.col})
    end
  end

  def link_cells(%PolarCell{} = cell, linked) do
    PolarCell.link_cells(cell, linked)
  end
  def link_cells(%HexCell{} = cell, linked) do
    HexCell.link_cells(cell, linked)
  end
  def link_cells(%TriangleCell{} = cell, linked) do
    TriangleCell.link_cells(cell, linked)
  end
  def link_cells(%OverCell{} = cell, linked) do
    OverCell.link_cells(cell, linked)
  end
  def link_cells(%Cell3d{} = cell, linked) do
    Cell3d.link_cells(cell, linked)
  end
  def link_cells(cell, linked) do
    new_cell = link(cell, linked)
    new_linked = link(linked, new_cell)

    {new_cell, new_linked}
  end

  def unlink_cells(cell, linked) do
    new_cell = unlink(cell, linked)
    new_linked = unlink(linked, cell)

    {new_cell, new_linked}
  end

  def add_weight(cell, weight) do
    %Cell{cell | weight: weight}
  end

  def neighbors(%PolarCell{} = cell) do
    PolarCell.neighbors(cell)
  end
  def neighbors(%HexCell{} = cell) do
    HexCell.neighbors(cell)
  end
  def neighbors(%TriangleCell{} = cell) do
    TriangleCell.neighbors(cell)
  end
  def neighbors(%OverCell{} = cell) do
    OverCell.neighbors(cell)
  end
  def neighbors(%Cell3d{} = cell) do
    Cell3d.neighbors(cell)
  end
  def neighbors(cell) do
    [cell.north, cell.east, cell.south, cell.west]
    |> Enum.filter(fn dir -> dir != nil end)
  end

  def update_neighbors(cell, north, east, south, west) do
    %Cell{cell | north: north, east: east, south: south, west: west} 
  end

  def to_string(cell, top, bot, distances \\ nil) do
    cell = if cell == nil do
      Cell.initialize(-1, -1)
    else
      cell
    end
    body = contents_of(cell, distances)
    east_boundary = if linked?(cell, cell.east), do: " ", else: "|"
    top = top <> body <> east_boundary

    south_boundary = if linked?(cell, cell.south), do: "   ", else: "---"
    corner = "+"
    bot = bot <> south_boundary <> corner

    {top, bot}
  end

  defp contents_of(cell, distances) do
    case distances do
      nil -> "   "
      _ -> case Distances.distance(distances, cell) do
        nil -> "   " 
        d -> " #{Integer.to_string(d, 36)} "
      end
    end
  end

  def background_color(dist, max, weight, use_weights) do
    case use_weights do
      true -> background_color(dist, max, weight)
      false -> background_color(dist, max)
    end
  end
  def background_color(dist, max, weight) do
    if weight > 1 do
      ExPng.Color.rgb(255, 0, 0)
    else
      case dist do
        nil -> ExPng.Color.white()
        _ -> 
          intensity = (64 + 191 * (max - dist) / max) |> trunc()
          ExPng.Color.rgb(intensity, intensity, 0)
      end
    end 
  end 
  def background_color(dist, max) when max == 0 do
    color = case dist do
      nil -> ExPng.Color.white()
      _d -> ExPng.Color.rgb(0, 0, 128)
    end

    case dist do
      nil -> ExPng.Color.white()
      _d -> color
    end
  end
  def background_color(dist, max) do
    case dist do
      nil -> ExPng.Color.white()
      d -> 
        intensity = (max - d) / max
        dark = Float.round(255 * intensity) |> trunc()
        bright = 128 + Float.round(127 * intensity) |> trunc()
        ExPng.Color.rgb(dark, dark, bright)
    end
  end

  # TODO: Add colors for mazes with insets
  def draw_background(cell, image, cell_size, bg) do
    x1 = cell.col * cell_size
    y1 = cell.row * cell_size 
    x2 = (cell.col + 1) * cell_size
    y2 = (cell.row + 1) * cell_size

    Enum.reduce(x1..x2, image, fn x, acc ->
      ExPng.Image.line(acc, {x, y1}, {x, y2}, bg)
    end)
  end

  def draw_walls(%UnderCell{} = cell, image, cell_size, wall, inset) do
    [x1, x2, x3, x4,
      y1, y2, y3, y4] = cell_coordinates_with_inset(
        cell.col * cell_size,
        cell.row * cell_size,
        cell_size,
        inset)

    if UnderCell.vertical_passage?(cell) do
      ExPng.Image.line(image, {x2, y1}, {x2, y2}, wall)
      |> ExPng.Image.line({x3, y1}, {x3, y2}, wall) 
      |> ExPng.Image.line({x2, y3}, {x2, y4}, wall) 
      |> ExPng.Image.line({x3, y3}, {x3, y4}, wall) 
    else
      ExPng.Image.line(image, {x1, y2}, {x2, y2}, wall)
      |> ExPng.Image.line({x1, y3}, {x2, y3}, wall) 
      |> ExPng.Image.line({x3, y2}, {x4, y2}, wall) 
      |> ExPng.Image.line({x3, y3}, {x4, y3}, wall) 
    end
  end
  def draw_walls(%OverCell{} = cell, image, cell_size, wall, inset) do
    draw_walls_with_inset(cell, image, cell_size, wall, inset, cell.col, cell.row) 
  end
  def draw_walls(cell, image, _cell_size, _wall, _inset) when cell == nil do
    image
  end
  def draw_walls(cell, image, cell_size, wall, inset) do
    case inset do
      0 -> draw_walls(cell, image, cell_size, wall, cell.col, cell.row)
      _ -> draw_walls_with_inset(cell, image, cell_size, wall, inset, cell.col, cell.row)
    end 
  end
  def draw_walls(cell, image, _cell_size, _wall, _x, _y) when cell == nil do
    image
  end
  def draw_walls(cell, image, cell_size, wall, x, y, multiply \\ true) do
    scale = if multiply, do: cell_size, else: 1
    x1 = x * scale
    y1 = y * scale
    {x2, y2} = if multiply do
      x2 = (x + 1) * cell_size
      y2 = (y + 1) * cell_size
      {x2, y2}
    else
      x2 = x + cell_size
      y2 = y + cell_size
      {x2, y2}
    end

    image = case cell.north do
      nil -> ExPng.Image.line(image, {x1, y1}, {x2, y1}, wall)
      _neighbor -> image
    end

    image = case cell.west do
      nil -> ExPng.Image.line(image, {x1, y1}, {x1, y2}, wall)
      _neighbor -> image
    end

    image = case linked?(cell, cell.east) do
      true -> image
      false -> ExPng.Image.line(image, {x2, y1}, {x2, y2}, wall)
    end

    case linked?(cell, cell.south) do
      true -> image
      false -> ExPng.Image.line(image, {x1, y2}, {x2, y2}, wall)
    end
  end

  def draw_walls_with_inset(cell, image, cell_size, wall, inset, x, y) do
    [x1, x2, x3, x4,
      y1, y2, y3, y4] = cell_coordinates_with_inset(
        x * cell_size,
        y * cell_size,
        cell_size,
        inset)

    image = case linked?(cell, cell.north) do
      true ->
        ExPng.Image.line(image, {x2, y1}, {x2, y2}, wall)
        |> ExPng.Image.line({x3, y1}, {x3, y2}, wall)
      false -> ExPng.Image.line(image, {x2, y2}, {x3, y2}, wall)
    end

    image = case linked?(cell, cell.south) do
      true ->
        ExPng.Image.line(image, {x2, y3}, {x2, y4}, wall)
        |> ExPng.Image.line({x3, y3}, {x3, y4}, wall)
      false -> ExPng.Image.line(image, {x2, y3}, {x3, y3}, wall)
    end

    image = case linked?(cell, cell.west) do
      true ->
        ExPng.Image.line(image, {x1, y2}, {x2, y2}, wall)
        |> ExPng.Image.line({x1, y3}, {x2, y3}, wall)
      false -> ExPng.Image.line(image, {x2, y2}, {x2, y3}, wall)
    end

    case linked?(cell, cell.east) do
      true ->
        ExPng.Image.line(image, {x3, y2}, {x4, y2}, wall)
        |> ExPng.Image.line({x3, y3}, {x4, y3}, wall)
      false -> ExPng.Image.line(image, {x3, y2}, {x3, y3}, wall)
    end
  end

  defp cell_coordinates_with_inset(x, y, cell_size, inset) do
    x1 = x
    x4 = x + cell_size
    x2 = x1 + inset
    x3 = x4 - inset

    y1 = y
    y4 = y + cell_size
    y2 = y1 + inset
    y3 = y4 - inset
    [x1, x2, x3, x4, y1, y2, y3, y4]
  end

  def get_row_col(%Cell3d{} = cell) do
    Cell3d.get_location(cell)
  end
  def get_row_col(cell) do
    case cell do
      nil -> nil
      c -> {c.row, c.col}
    end
  end

  def eq?(%Cell3d{} = cell, other) do
    cell.row === other.row && cell.col === other.col && cell.level === other.level
  end
  def eq?(cell, other) do
    cell.row === other.row && cell.col === other.col
  end

end
