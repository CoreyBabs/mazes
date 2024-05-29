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
    cell = %Cell{cell | links: new_links}

    cell
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
    new_linked = link(linked, cell)

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

  def to_string(cell, top, bot) do
    body = "   "
    east_boundary = if linked?(cell, cell.east), do: " ", else: "|"
    top = top <> body <> east_boundary

    south_boundary = if linked?(cell, cell.south), do: "   ", else: "---"
    corner = "+"
    bot = bot <> south_boundary <> corner

    {top, bot}
  end

  def get_row_col(cell) do
    case cell do
      nil -> nil
      c -> {c.row, c.col}
    end
  end

end
