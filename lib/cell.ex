defmodule Cell do
  defstruct [:row, :col, :north, :south, :east, :west, :links]

  def initialize(row, column) do
    %Cell{row: row, col: column, links: %{}}
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
  def linked?(cell, other_cell) do
    case other_cell do
      nil -> false
      _ -> Map.has_key?(cell.links, {other_cell.row, other_cell.col})
    end
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

  def neighbors(cell) do
    [cell.north, cell.east, cell.south, cell.west]
    |> Enum.filter(fn dir -> dir != nil end)
  end

  def update_neighbors(cell, north, east, south, west) do
    %Cell{cell | north: north, east: east, south: south, west: west} 
  end

  def to_string(cell, top, bot, distances \\ nil) do
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

  def draw_background(cell, image, cell_size, bg) do
    x1 = cell.col * cell_size
    y1 = cell.row * cell_size 
    x2 = (cell.col + 1) * cell_size
    y2 = (cell.row + 1) * cell_size

    Enum.reduce(x1..x2, image, fn x, acc ->
      ExPng.Image.line(acc, {x, y1}, {x, y2}, bg)
    end)
  end

  def draw_walls(cell, image, cell_size, wall) do
    x1 = cell.col * cell_size
    y1 = cell.row * cell_size 
    x2 = (cell.col + 1) * cell_size
    y2 = (cell.row + 1) * cell_size

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

  def get_row_col(cell) do
    case cell do
      nil -> nil
      c -> {c.row, c.col}
    end
  end

end
