defmodule UnderCell do
  
  defstruct [:row, :col, :north, :south, :east, :west, :links, :weight]

  def initialize(over_cell) do
    cell = %UnderCell{row: over_cell.row, col: over_cell.col, links: %{}, weight: 1}

    if OverCell.horizontal_passage?(over_cell) do
      cell = %UnderCell{cell | north: over_cell.north, south: over_cell.south} 
      north = Grid.get_cell(over_cell.grid, cell.north)
      south = Grid.get_cell(over_cell.grid, cell.south) 
      {cell, linked_n} = link_cells(cell, north)
      {cell, linked_s} = link_cells(cell, south)

      {{cell, linked_n, linked_s}, :vertical}
    else
      cell = %UnderCell{cell | east: over_cell.east, west: over_cell.west} 
      east = Grid.get_cell(over_cell.grid, cell.east)
      west = Grid.get_cell(over_cell.grid, cell.west) 
      {cell, linked_e} = link_cells(cell, east)
      {cell, linked_w} = link_cells(cell, west)
      {{cell, linked_e, linked_w}, :horizontal}
    end
  end

  defp link(%OverCell{} = cell, linked) do
    new_links = cell.links
    new_links = Map.put(new_links, Cell.get_row_col(linked), true)
    %OverCell{cell | links: new_links}
  end
  defp link(cell, linked) do
    new_links = cell.links
    new_links = Map.put(new_links, Cell.get_row_col(linked), true)
    %UnderCell{cell | links: new_links}
  end

  def link_cells(cell, linked) do
    new_cell = link(cell, linked)
    new_linked = link(linked, new_cell)

    {new_cell, new_linked}
  end

  def horizontal_passage?(cell) do
    cell.east != nil || cell.west != nil
  end

  def vertical_passage?(cell) do
    cell.north != nil || cell.south != nil
  end
end
