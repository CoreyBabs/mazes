defmodule Grid do

  defstruct [:rows, :cols, :cells]

  def initialize(rows, cols) do
    %Grid{rows: rows, cols: cols} 
    |> prepare_grid()
    |> configure_cells()
  end
  
  def prepare_grid(grid) do
    cells = Enum.map(0..grid.rows - 1, fn row ->
      Enum.map(0..grid.cols - 1, fn col ->
        Cell.initialize(row, col)
      end)
    end) 

    %Grid{grid | cells: cells}
  end

  def configure_cells(grid) do
    test = Enum.with_index(grid.cells) 
    IO.inspect(test)
    # TODO: This is not working correctly as the indices are wrong which is leading to an error
    # I think this is showing the signs of a larger problem with updating cells as well
    Enum.with_index(Enum.with_index(grid.cells)) |> Enum.map(fn {{column, row}, col} ->  
      IO.puts(row)
      IO.puts(col)
      IO.inspect(column)
      north = get_cell(grid, row - 1, col)
      east = get_cell(grid, row, col + 1)
      south = get_cell(grid, row + 1, col)
      west = get_cell(grid, row, col - 1)
      update_cell(grid, column, row, col, north, east, south, west)
    end)
  end

  def random_cell(grid) do
    rand_row = Enum.random(0..grid.rows - 1)
    rand_col = Enum.random(0..grid.cols - 1)

    get_cell(grid, rand_row, rand_col)
  end

  def size(grid) do
    grid.rows * grid.cols
  end

  def each_row(grid) do
    Stream.each(grid.cells, fn row -> row end)
  end

  def each_cell(grid) do
    each_row(grid)
    |> Stream.each(fn col -> col end)
  end

  defp get_cell(grid, row, col) do
    Enum.at(Enum.at(grid.cells, row), col)
  end

  defp update_cell(grid, column, row, col, north, east, south, west) do
    new_cell = Enum.at(column, col)
    |> Cell.update_neighbors(north, east, south, west)

    new_col = Enum.at(grid.cells, row)
    |> List.update_at(col, fn _ -> new_cell end)

    new_cells = List.update_at(grid.cells, row, fn _ -> new_col end)
    %{grid | cells: new_cells}
  end

  defp index_to_row_col(size, index) do
    
  end
end
