defmodule WeaveGrid do
  
  defstruct [:rows, :cols, :cells, mask: nil, under_cells: []]


  def initialize(rows, cols, preconfigured \\ false) do
    %WeaveGrid{rows: rows, cols: cols} 
    |> prepare_grid(preconfigured)
    |> configure_cells()
  end

  def prepare_grid(grid, preconfigred) do
    cells = Enum.map(0..grid.rows - 1, fn row ->
      Enum.map(0..grid.cols - 1, fn col ->
        if grid.mask == nil or Mask.get(grid.mask, row, col) do
          OverCell.initialize(row, col, preconfigred)
        else
          nil
        end
      end)
    end) 
    
    %WeaveGrid{grid | cells: cells}
    |> update_cells_with_grid()
  end

  def configure_cells(grid) do
    each_cell(grid)
    |> Enum.filter(fn c -> c != nil end)
    |> Enum.reduce(grid, fn cell, acc ->  
      north = Grid.get_cell(acc, cell.row - 1, cell.col) |> Cell.get_row_col()
      east = Grid.get_cell(acc, cell.row, cell.col + 1) |> Cell.get_row_col()
      south = Grid.get_cell(acc, cell.row + 1, cell.col) |> Cell.get_row_col()
      west = Grid.get_cell(acc, cell.row, cell.col - 1) |> Cell.get_row_col()
      update_cell_with_neighbors(acc, cell.row, cell.col, north, east, south, west)
    end)
  end

  # This function really slows down weaved grids and gives a higher memory footprint
  # this can be avoided but would require refactoring all algorithms and other grids and cell types.
  def update_cells_with_grid(grid) do
    Grid.each_cell(grid) |>
    Enum.reduce(grid, fn c, acc ->
      OverCell.set_grid(c, grid) # Not using acc here is intended so every cell has the same grid
      |> update_grid_with_cell(acc)
    end)
  end

  def update_grid_with_cell(cell, grid) when cell == nil do
    grid
  end
  def update_grid_with_cell(%UnderCell{} = _cell, grid) do
    grid
  end
  def update_grid_with_cell(cell, grid) do
    new_col = Enum.at(grid.cells, cell.row)
    |> List.update_at(cell.col, fn _ -> cell end)

    new_cells = List.update_at(grid.cells, cell.row, fn _ -> new_col end)
    %WeaveGrid{grid | cells: new_cells}
  end

  def update_grid_with_cells(grid, cells) do
    Enum.reduce(cells, grid, fn cell, acc -> update_grid_with_cell(cell, acc) end)
  end

  def each_cell(grid) do
    over_cells = Grid.each_row(grid)
    |> Enum.flat_map(fn col -> col end)

    over_cells ++ grid.under_cells
  end

  def add_under_cell(grid, under) do
    %WeaveGrid{grid | under_cells: grid.under_cells ++ [under]} 
  end

  def tunnel_under(grid, cell) do
    {{under_cell, l1, l2}, dir} = UnderCell.initialize(cell) 
    under = Cell.get_row_col(under_cell)

    grid = update_grid_with_cell(l1, grid)
    grid = update_grid_with_cell(l2, grid)

    grid = case dir do
      :vertical ->
        north = Grid.get_cell(grid, cell.north)
        south = Grid.get_cell(grid, cell.south)
        
        north = %OverCell{north | south: under}
        south = %OverCell{south | north: under}

        grid = update_grid_with_cell(north, grid)
        update_grid_with_cell(south, grid)
      :horizontal ->
        east = Grid.get_cell(grid, cell.east)
        west = Grid.get_cell(grid, cell.west)

        east = %OverCell{east | west: under}
        west = %OverCell{west | east: under}

        grid = update_grid_with_cell(east, grid)
        update_grid_with_cell(west, grid)
    end 

    add_under_cell(grid, under_cell)
  end

  defp update_cell_with_neighbors(grid, row, col, north, east, south, west) do
    new_cell = Enum.at(grid.cells, row)
    |> Enum.at(col)
    |> OverCell.update_neighbors(north, east, south, west)

    update_grid_with_cell(new_cell, grid)
  end

  def to_png(grid, cell_size, inset) when inset == nil or inset == 0 do
    Grid.to_png(grid, cell_size, 0.1) 
  end
  def to_png(grid, cell_size, inset) do
    cell_size = cell_size * 10
    img_width = cell_size * grid.cols
    img_height = cell_size * grid.rows
    inset = (cell_size * inset) |> trunc()

    wall = ExPng.Color.black()

    img = ExPng.Image.new(img_width + 1, img_height + 1)

    each_cell(grid)
    |> Enum.reduce(img, fn cell, acc -> Cell.draw_walls(cell, acc, cell_size, wall, inset) end) 
  end
end
