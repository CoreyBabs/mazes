defmodule Prims do
 
  def on(grid, start) do
    active = [Cell.get_row_col(start)]
    costs = %{}
    costs = Grid.each_cell(grid)
    |> Enum.reduce(costs, fn cell, acc ->
      Map.put(acc, Cell.get_row_col(cell), Enum.random(0..99))
    end)

    loop_active(grid, active, costs)
  end

  def loop_active(grid, active, _costs) when length(active) == 0 do
    grid
  end
  def loop_active(grid, active, costs) do
    cell = Enum.min_by(active, fn c -> Map.get(costs, c) end)
    cell = Grid.get_cell(grid, cell) 

    available = Enum.filter(Cell.neighbors(cell), fn c ->
      Grid.get_cell(grid, c)
      |> Cell.links()
      |> Enum.empty?()
    end)
    
    {grid, active} = if Enum.any?(available) do
      neighbor = Enum.min_by(available, fn c -> Map.get(costs, c) end)
      neighbor = Grid.get_cell(grid, neighbor)
      grid = Grid.link_cells_and_update_grid(grid, cell, neighbor)
      active = active ++ [Cell.get_row_col(neighbor)]
      {grid, active}
    else
      active = List.delete(active, Cell.get_row_col(cell))
      {grid, active}
    end

    loop_active(grid, active, costs)
  end
end
