defmodule BinaryTree do
  def on(grid) do
    Grid.each_cell(grid)
    |> Enum.reduce(grid, fn cell, acc ->
      update_cell_with_neighbors(acc, cell)
    end)
  end

  defp update_cell_with_neighbors(grid, cell) do
    cell = Grid.get_cell(grid, Cell.get_row_col(cell))
    neighbors = []
    neighbors = case cell.north do
      nil -> neighbors
      north -> neighbors ++ [north]
    end

    neighbors = case Grid.get_cell(grid, cell.row, cell.col + 1) |> Cell.get_row_col() do
      nil -> neighbors
      east -> neighbors ++ [east]
    end

    case neighbors do
      [] -> grid
      list -> 
        neighbor = Enum.random(list)
        neighbor = Grid.get_cell(grid, neighbor)
        Grid.link_cells_and_update_grid(grid, cell, neighbor)
    end
  end
end
