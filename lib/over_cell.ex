defmodule OverCell do
  defstruct [:row, :col, :north, :south, :east, :west, :links, :weight, :grid, :simple]

  def initialize(row, column, simple) do
    %OverCell{row: row, col: column, links: %{}, weight: 1, grid: nil, simple: simple}
  end

  def neighbors(cell) do
    list = normal_neighbors(cell)
    if !cell.simple do
      north = Grid.get_cell(cell.grid, cell.north)
      south = Grid.get_cell(cell.grid, cell.south)
      east = Grid.get_cell(cell.grid, cell.east)
      west = Grid.get_cell(cell.grid, cell.west)

      list = if can_tunnel_north?(north), do: list ++ [north.north], else: list
      list = if can_tunnel_south?(south), do: list ++ [south.south], else: list
      list = if can_tunnel_east?(east), do: list ++ [east.east], else: list
      if can_tunnel_west?(west), do: list ++ [west.west], else: list
    else
      list
    end
  end

  defp normal_neighbors(cell) do
    [cell.north, cell.east, cell.south, cell.west]
    |> Enum.filter(fn dir -> dir != nil end)
  end

  def update_neighbors(cell, north, east, south, west) do
    %OverCell{cell | north: north, east: east, south: south, west: west} 
  end

  def link_cells(cell, linked) do
    neighbor = cond do
      cell.north != nil && cell.north == linked.south -> cell.north
      cell.south != nil && cell.south == linked.north -> cell.south
      cell.east != nil && cell.east == linked.west -> cell.east
      cell.west != nil && cell.west == linked.east -> cell.west
      true -> nil
    end 

    if neighbor != nil do
      {neighbor, :tunnel}
    else
      new_cell = link(cell, linked)
      new_linked = link(linked, new_cell)

      {new_cell, new_linked}
    end
  end

  def set_grid(%UnderCell{} = cell, _grid) do
    cell
  end
  def set_grid(cell, grid) do
    %OverCell{cell | grid: grid}
  end
  
  defp link(cell, linked) do
    new_links = cell.links
    new_links = Map.put(new_links, {linked.row, linked.col}, true)
    %OverCell{cell | links: new_links}
  end

  defp can_tunnel_north?(north) do
    north != nil && Grid.get_cell(north.grid, north.north) != nil && horizontal_passage?(north)
  end

  defp can_tunnel_south?(south) do
    south != nil && Grid.get_cell(south.grid, south.south) != nil && horizontal_passage?(south)
  end
  defp can_tunnel_east?(east) do
    east != nil && Grid.get_cell(east.grid, east.east) != nil && vertical_passage?(east) 
  end
  defp can_tunnel_west?(west) do
    west != nil && Grid.get_cell(west.grid, west.west) != nil && vertical_passage?(west) 
  end

  def horizontal_passage?(cell) do
    Cell.linked?(cell, cell.east) && Cell.linked?(cell, cell.west)
    && !Cell.linked?(cell, cell.north) && !Cell.linked?(cell, cell.south)
  end

  def vertical_passage?(cell) do
    Cell.linked?(cell, cell.north) && Cell.linked?(cell, cell.south)
    && !Cell.linked?(cell, cell.east) && !Cell.linked?(cell, cell.west)
  end
end
