defmodule BinaryTree do
  def on(grid) do
    grid = Grid.each_cell(grid)
    |> Enum.reduce(grid, fn cell, acc ->
      cells = update_cell_with_neighbors(cell)
      Grid.update_grid_with_cells(acc, Tuple.to_list(cells)) end)

    IO.inspect(grid)
    grid
  end

  defp update_cell_with_neighbors(cell) do
    neighbors = []
    neighbors = case cell.north do
      nil -> neighbors
      north -> neighbors ++ [north]
    end

    neighbors = case cell.east do
      nil -> neighbors
      east -> neighbors ++ [east]
    end

    case neighbors do
      [] -> {cell, nil}
      list -> 
        neighbor = Enum.random(list)
        Cell.link_cells(cell, neighbor)
    end
  end
end
