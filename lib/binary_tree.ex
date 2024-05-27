defmodule BinaryTree do
  def on(grid) do
    Grid.each_cell(grid)
    |> Enum.reduce(grid, fn cell, acc ->
      update_cell_with_neighbors(cell)
      |> Grid.update_grid_with_cell(acc) end)
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
      [] -> cell
      list -> 
        neighbor = Enum.random(list)
        Cell.link(cell, neighbor)
    end
  end
end
