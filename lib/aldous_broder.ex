defmodule AldousBroder do
  def on(grid) do
    cell = Grid.random_cell(grid)
    unvisited = Grid.size(grid) - 1
    check_and_update_cell(grid, cell, unvisited)
  end

  defp check_and_update_cell(grid, cell, unvisited) do
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
    if Enum.empty?(Cell.links(neighbor)) do
      new_cells = Cell.link_cells(cell, neighbor) 
      {new_cells, unvisited - 1}
    else
      {{cell, neighbor}, unvisited}
    end
  end

  defp update_grid_with_cells(grid, new_cells, update) do
    if update do
      Grid.update_grid_with_cells(grid, Tuple.to_list(new_cells))
    else
      grid
    end
  end
end
