defmodule Cell3d do
  
  defstruct [:row, :col, :north, :south, :east, :west, :links, :weight, :level, :up, :down]

  def initialize(level, row, col) do
    %Cell3d{row: row, col: col, links: %{}, weight: 1, level: level}
  end

  def neighbors(cell) do
    [cell.north, cell.east, cell.south, cell.west, cell.up, cell.down]
    |> Enum.filter(fn dir -> dir != nil end)
  end

  def link_cells(cell, linked) do
    new_cell = link(cell, linked)
    new_linked = link(linked, new_cell)

    {new_cell, new_linked}
  end

  defp link(cell, linked) do
    new_links = cell.links
    new_links = Map.put(new_links, {linked.level, linked.row, linked.col}, true)
    %Cell3d{cell | links: new_links}
  end

  def get_location(cell) do
    case cell do
      nil -> nil
      _ -> {cell.level, cell.row, cell.col}
    end
  end

  def update_neighbors(cell, north, east, south, west, up, down) do
    %Cell3d{cell | north: north, east: east, south: south, west: west, up: up, down: down} 
  end
end
