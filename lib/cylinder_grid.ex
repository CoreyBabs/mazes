defmodule CylinderGrid do
  
  defstruct [:rows, :cols, :cells, :mask]

  def initialize(rows, cols) do
    %CylinderGrid{rows: rows, cols: cols} 
    |> prepare_grid()
    |> Grid.configure_cells()
  end

  def prepare_grid(grid) do
    cells = Enum.map(0..grid.rows - 1, fn row ->
      Enum.map(0..grid.cols - 1, fn col ->
        if grid.mask == nil or Mask.get(grid.mask, row, col) do
          Cell.initialize(row, col)
        else
          nil
        end
      end)
    end) 
    %CylinderGrid{grid | cells: cells}
  end

  def update_grid_with_cell(cell, grid) do
    new_col = Enum.at(grid.cells, cell.row)
    |> List.update_at(cell.col, fn _ -> cell end)

    new_cells = List.update_at(grid.cells, cell.row, fn _ -> new_col end)
    %CylinderGrid{grid | cells: new_cells}
  end

  def get_cell(grid, row, col) do
    case Enum.at(grid.cells, row) do
      nil -> nil
      cols -> Enum.at(cols, rem(col, length(cols)))
    end
  end
end
