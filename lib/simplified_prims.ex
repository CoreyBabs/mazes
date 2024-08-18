defmodule SimplifiedPrims do
  def on(grid, start) do
    active = [Cell.get_row_col(start)]

    loop_active(grid, active)
  end

  def loop_active(grid, active) when length(active) == 0 do
    grid
  end
  def loop_active(grid, active) do
    cell = Enum.random(active)
    cell = Grid.get_cell(grid, cell) 

    available = Enum.filter(Cell.neighbors(cell), fn c ->
      Grid.get_cell(grid, c)
      |> Cell.links()
      |> Enum.empty?()
    end)
    
    {grid, active} = if Enum.any?(available) do
      neighbor = Enum.random(available)
      neighbor = Grid.get_cell(grid, neighbor)
      grid = Grid.link_cells_and_update_grid(grid, cell, neighbor)
      active = active ++ [Cell.get_row_col(neighbor)]
      {grid, active}
    else
      active = List.delete(active, Cell.get_row_col(cell))
      {grid, active}
    end

    loop_active(grid, active)
  end
end
