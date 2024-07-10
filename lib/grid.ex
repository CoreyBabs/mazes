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
    idxs =
      for i <- 0..(grid.rows - 1),
          j <- 0..(grid.cols - 1) do
            {i, j}
      end
    
    idxs |> Enum.reduce(grid, fn {row, col}, acc ->  
      north = get_cell(acc, row - 1, col) |> Cell.get_row_col()
      east = get_cell(acc, row, col + 1) |> Cell.get_row_col()
      south = get_cell(acc, row + 1, col) |> Cell.get_row_col()
      west = get_cell(acc, row, col - 1) |> Cell.get_row_col()
      update_cell_with_neighbors(acc, row, col, north, east, south, west)
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
    Enum.map(grid.cells, fn row -> row end)
  end

  def each_cell(grid) do
    each_row(grid)
    |> Enum.flat_map(fn col -> col end)
  end

  def update_grid_with_cell(cell, grid) when cell == nil do
    grid
  end
  def update_grid_with_cell(cell, grid) do
    new_col = Enum.at(grid.cells, cell.row)
    |> List.update_at(cell.col, fn _ -> cell end)

    new_cells = List.update_at(grid.cells, cell.row, fn _ -> new_col end)
    %Grid{grid | cells: new_cells}
  end

  def update_grid_with_cells(grid, cells) do
    Enum.reduce(cells, grid, fn cell, acc -> update_grid_with_cell(cell, acc) end)
  end

  def to_string(grid, distances \\ nil) do
    output = "+" <> String.duplicate("---+", grid.cols) <> "\n"
    each_row(grid)
    |> Enum.reduce(output, fn row, acc -> 
      top = "|"
      bot = "+"
      {top, bot} = Enum.reduce(row, {top, bot}, fn cell, {top, bot} -> Cell.to_string(cell, top, bot, distances) end)
      acc = acc <> top <> "\n"
      acc <> bot <> "\n"
    end)
  end

  def to_png(grid, cell_size) do
    cell_size = cell_size * 10
    img_width = cell_size * grid.cols
    img_height = cell_size * grid.rows

    wall = ExPng.Color.black()

    img = ExPng.Image.new(img_width + 1, img_height + 1)

    each_cell(grid)
    |> Enum.reduce(img, fn cell, acc -> Cell.draw_walls(cell, acc, cell_size, wall) end) 
  end

  def to_png_with_color(grid, cell_size, distances, max) do
    cell_size = cell_size * 10
    img_width = cell_size * grid.cols
    img_height = cell_size * grid.rows

    wall = ExPng.Color.black()

    img = ExPng.Image.new(img_width + 1, img_height + 1)

    img = case distances do
      nil -> img
      dists -> each_cell(grid)
        |> Enum.reduce(img, fn cell, acc ->
          dist = Distances.distance(dists, cell)
          Cell.draw_background(
            cell,
            acc,
            cell_size,
            Cell.background_color(dist, max))
        end) 
    end

    each_cell(grid)
    |> Enum.reduce(img, fn cell, acc -> Cell.draw_walls(cell, acc, cell_size, wall) end) 
  end

  def get_cell(_grid, row, col) when row < 0 or col < 0 do
    nil
  end  
  def get_cell(grid, row, col) do
    case Enum.at(grid.cells, row) do
      nil -> nil
      cols -> Enum.at(cols, col)
    end
  end
  def get_cell(_grid, {row, col}) when row < 0 or col < 0 do
    nil
  end
  def get_cell(grid, {row, col}) do
    case Enum.at(grid.cells, row) do
      nil -> nil
      cols -> Enum.at(cols, col)
    end
  end

  defp update_cell_with_neighbors(grid, row, col, north, east, south, west) do
    new_cell = Enum.at(grid.cells, row)
    |> Enum.at(col)
    |> Cell.update_neighbors(north, east, south, west)

    update_grid_with_cell(new_cell, grid)
  end

  def distances_from_cell(grid, cell) do
    distances = Distances.initialize(cell)
    frontier = [cell]

    distances_from_cell(grid, distances, frontier)
  end

  def deadends(grid) do
    Grid.each_cell(grid)
    |> Enum.filter(fn cell -> Cell.links(cell)
      |> length() == 1
    end)
  end

  defp distances_from_cell(grid, distances, frontier) do
    case frontier do
      [] -> distances
      _f -> 
        {distances, frontier} = Enum.reduce(frontier, {distances, frontier}, fn c, {acc, nf} -> 
          Enum.reduce(c.links, {acc, nf}, fn {linked, _}, {acc_d, acc_f} -> 
            distances_of_linked(grid, acc_d, c, linked, acc_f)
          end)
        end)

        distances_from_cell(grid, distances, frontier)
    end
  end

  defp distances_of_linked(grid, distances, cell, linked, frontier) do
    case Distances.distance(distances, linked) do
      nil -> {Distances.put(distances, linked, Distances.distance(distances, cell) + 1), frontier ++ [get_cell(grid, linked)]}
      _distance -> {distances, List.delete(frontier, cell)}
    end
  end
end
