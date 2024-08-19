defmodule RecursiveDivision do
  
  def on(grid) do
    grid = Grid.each_cell(grid)
    |> Enum.reduce(grid, fn cell, acc ->
        Cell.neighbors(cell) |> Enum.reduce(acc, fn n, g ->
          neighbor = Grid.get_cell(g, n)
          if Cell.linked?(cell, neighbor) do
            g
          else
            Grid.link_cells_and_update_grid(g, cell, neighbor)
          end
        end)
      end)

    divide(grid, 0, 0, grid.rows, grid.cols)
  end

  def divide(grid, row, col, height, width) do
    if height <= 1 || width <= 1 || (height < 5 && width < 5 && Enum.random(0..3) == 0) do
      grid
    else
      cond do
        height > width -> divide_horizontally(grid, row, col, height, width)
        true -> divide_vertically(grid, row, col, height, width)
      end
    end 
  end

  def divide_horizontally(grid, row, col, height, width) do
    divide_south_of = Enum.random(0..height - 2)
    passage_at = Enum.random(0..width - 1)

    grid = 0..(width - 1)
    |> Enum.reduce(grid, fn x, acc ->
      if passage_at == x do
        acc
      else
        cell = Grid.get_cell(acc, row + divide_south_of, col + x)
        south = Grid.get_cell(acc, cell.south)
        {cell, south} = Cell.unlink_cells(cell, south)
        acc = Grid.update_grid_with_cell(cell, acc)
        acc = Grid.update_grid_with_cell(south, acc)
        acc
      end
    end)

    divide(grid, row, col, divide_south_of + 1, width)
    |> divide(row + divide_south_of + 1, col, height - divide_south_of - 1, width)
  end

  def divide_vertically(grid, row, col, height, width) do
    divide_east_of = Enum.random(0..width - 2)
    passage_at = Enum.random(0..height - 1)

    grid = 0..(height - 1)
    |> Enum.reduce(grid, fn y, acc ->
      if passage_at == y do
        acc
      else
        cell = Grid.get_cell(acc, row + y, col + divide_east_of)
        east = Grid.get_cell(acc, cell.east)
        {cell, east} = Cell.unlink_cells(cell, east)
        acc = Grid.update_grid_with_cell(cell, acc)
        acc = Grid.update_grid_with_cell(east, acc)
        acc
      end
    end)

    divide(grid, row, col, height, divide_east_of + 1)
    |> divide(row, col + divide_east_of + 1, height, width - divide_east_of - 1)
  end
end
