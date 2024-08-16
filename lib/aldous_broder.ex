defmodule AldousBroder do
  def on(grid) do
    cell = Grid.random_cell(grid)
    unvisited = Grid.size(grid) - 1
    check_and_update_cell(grid, cell, unvisited)
  end

  defp check_and_update_cell(grid, cell, unvisited) do
    cell = Grid.get_cell(grid, Cell.get_row_col(cell))
    case unvisited do
      0 -> grid
      _ -> 
        {new_cells, new_unvisited} = link_random_cell(grid, cell, unvisited)
        update_grid_with_cells(grid, new_cells, new_unvisited == unvisited - 1) 
        |> check_and_update_cell(elem(new_cells, 1), new_unvisited)
    end
  end

  defp link_random_cell(grid, cell, unvisited) do
    neighbor = Cell.neighbors(cell) |> Enum.random()
    neighbor = Grid.get_cell(grid, neighbor)
    unvisited = if Enum.empty?(Cell.links(neighbor)) do
      unvisited - 1
    else
      unvisited 
    end

    {{cell, neighbor}, unvisited}
  end

  defp update_grid_with_cells(grid, {cell, linked}, update) do
    if update do
      Grid.link_cells_and_update_grid(grid, cell, linked)
    else
      grid
    end
  end
end
