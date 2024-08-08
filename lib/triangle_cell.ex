defmodule TriangleCell do
  require Integer
  
  defstruct [:row, :col, :north, :south, :east, :west, :links]

  def initialize(row, column) do
    %TriangleCell{row: row, col: column, links: %{}}
  end

  def upright?(tcell) do
    Integer.is_even(tcell.row + tcell.col)
  end

  def neighbors(tcell) do
    list = [tcell.east, tcell.west]
    |> Enum.filter(fn dir -> dir != nil end)
    list = if !upright?(tcell) && tcell.north, do: list ++ [tcell.north], else: list
    list = if upright?(tcell) && tcell.south, do: list ++ [tcell.south], else: list
    list
  end

  def update_neighbors(cell, north, south, east, west) do
    %TriangleCell{cell | north: north, east: east, south: south, west: west} 
  end

  def link(cell, linked) do
    new_links = cell.links
    new_links = Map.put(new_links, {linked.row, linked.col}, true)
    %TriangleCell{cell | links: new_links}
  end

  def link_cells(cell, linked) do
    new_cell = link(cell, linked)
    new_linked = link(linked, new_cell)

    {new_cell, new_linked}
  end
end
