defmodule Grid3d do
  
  defstruct [:rows, :cols, :cells, :levels, mask: nil]

  def initialize(levels, rows, cols) do
    %Grid3d{rows: rows, cols: cols, levels: levels} 
    |> prepare_grid()
    |> configure_cells()
  end

  def prepare_grid(grid) do
    cells =
      Enum.map(0..grid.levels - 1, fn level -> 
        Enum.map(0..grid.rows - 1, fn row ->
          Enum.map(0..grid.cols - 1, fn col ->
            if grid.mask == nil or Mask.get(grid.mask, row, col) do
              Cell3d.initialize(level, row, col)
            else
              nil
            end
          end)
        end) 
      end)

    %Grid3d{grid | cells: cells}
  end

  def configure_cells(grid) do
    each_cell(grid)
    |> Enum.filter(fn c -> c != nil end)
    |> Enum.reduce(grid, fn cell, acc ->  
      north = get_cell(acc, cell.level, cell.row - 1, cell.col) |> Cell3d.get_location()
      east = get_cell(acc, cell.level, cell.row, cell.col + 1) |> Cell3d.get_location()
      south = get_cell(acc, cell.level, cell.row + 1, cell.col) |> Cell3d.get_location()
      west = get_cell(acc, cell.level, cell.row, cell.col - 1) |> Cell3d.get_location()
      up = get_cell(acc, cell.level + 1, cell.row, cell.col) |> Cell3d.get_location()
      down = get_cell(acc, cell.level - 1, cell.row, cell.col) |> Cell3d.get_location()
      update_cell_with_neighbors(acc, cell.level, cell.row, cell.col, north, east, south, west, up, down)
    end)
  end

  def get_cell(_grid, level, row, col) when row < 0 or col < 0 or level < 0 do
    nil
  end  
  def get_cell(grid, level, row, col) when row >= grid.rows or col >= grid.cols or level >= grid.levels do
    nil
  end  
  def get_cell(grid, level, row, col) do
    get_cell_base(grid, level, row, col)
  end
  def get_cell(_grid, {level, row, col}) when row < 0 or col < 0 or level < 0 do
    nil
  end
  def get_cell(grid, {level, row, col}) when row >= grid.rows or col >= grid.cols or level >= grid.levels do
    nil
  end  
  def get_cell(_grid, location) when location == nil do
    nil
  end
  def get_cell(grid, {level, row, col}) do
    get_cell_base(grid, level, row, col)
  end

  defp get_cell_base(grid, level, row, col) do
    Enum.at(grid.cells, level)
    |> Enum.at(row)
    |> Enum.at(col)
  end

  def random_cell(grid) do
    rand_level = Enum.random(0..grid.levels - 1)
    rand_row = Enum.random(0..grid.rows - 1)
    rand_col = Enum.random(0..grid.cols - 1)

    get_cell(grid, rand_level, rand_row, rand_col)
  end

  def size(grid) do
    grid.levels * grid.rows * grid.cols
  end

  def each_level(grid) do
    Enum.map(grid.cells, fn level -> level end)
  end

  def each_row(grid) do
    each_level(grid)
    |> Enum.flat_map(fn row -> row end)
  end

  def each_cell(grid) do
    each_row(grid)
    |> Enum.flat_map(fn col -> col end)
  end

  def update_grid_with_cell(cell, grid) when cell == nil do
    grid
  end
  def update_grid_with_cell(cell, grid) do
    new_col =
    Enum.at(grid.cells, cell.level)
    |> Enum.at(cell.row)
    |> List.update_at(cell.col, fn _ -> cell end)

    new_row = Enum.at(grid.cells, cell.level) |> List.update_at(cell.row, fn _ -> new_col end) 
    new_cells = List.update_at(grid.cells, cell.level, fn _ -> new_row end)
    %Grid3d{grid | cells: new_cells}
  end

  defp update_cell_with_neighbors(grid, level, row, col, north, east, south, west, up, down) do
    new_cell =
    Enum.at(grid.cells, level)
    |> Enum.at(row)
    |> Enum.at(col)
    |> Cell3d.update_neighbors(north, east, south, west, up, down)

    update_grid_with_cell(new_cell, grid)
  end

  def update_grid_with_cells(grid, cells) do
    Enum.reduce(cells, grid, fn cell, acc -> update_grid_with_cell(cell, acc) end)
  end

  def link_cells_and_update_grid(grid, cell, linked) do
    cells = Cell.link_cells(cell, linked) |> Tuple.to_list()
    update_grid_with_cells(grid, cells)
  end

  def to_png(grid, cell_size, inset) do
    to_png(grid, cell_size, inset, cell_size / 2 |> trunc())
  end
  def to_png(grid, cell_size, inset, margin) do
    inset = cell_size * inset |> trunc()

    grid_width = cell_size * grid.cols
    grid_height = cell_size * grid.rows
    img_width = grid_width * grid.levels + (grid.levels - 1) * margin
    img_height = grid_height

    wall = ExPng.Color.black()
    arrow = ExPng.Color.rgb(255, 0, 0)
    
    img = ExPng.Image.new(img_width + 1, img_height + 1)

    # TODO: Add background color
    each_cell(grid)
    |> Enum.reduce(img, fn cell, acc ->
      x = cell.level * (grid_width + margin) + cell.col * cell_size
      y = cell.row * cell_size

      acc = if inset > 0 do
        Cell.draw_walls_with_inset(cell, acc, cell_size, wall, inset, x, y)
      else
        Cell.draw_walls(cell, acc, cell_size, wall, x, y, false)
      end

      mid_x = x + cell_size / 2 |> trunc()
      mid_y = y + cell_size / 2 |> trunc()

      up = get_cell(grid, cell.up)
      down = get_cell(grid, cell.down)

      acc = if Cell.linked?(cell, down) do
        ExPngExtensions.line(acc, {mid_x - 3, mid_y}, {mid_x - 1, mid_y + 2}, arrow)
        |> ExPngExtensions.line({mid_x - 3, mid_y}, {mid_x - 1, mid_y - 2}, arrow)
      else
        acc
      end

      if Cell.linked?(cell, up) do
        ExPngExtensions.line(acc, {mid_x + 3, mid_y}, {mid_x + 1, mid_y + 2}, arrow)
        |> ExPngExtensions.line({mid_x + 3, mid_y}, {mid_x + 1, mid_y - 2}, arrow)
      else
        acc
      end
    end)
  end
end
