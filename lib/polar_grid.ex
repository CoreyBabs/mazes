defmodule PolarGrid do
  
  defstruct [:rows, :cols, :cells]

  def initialize(rows) do
    %PolarGrid{rows: rows, cols: 1}
    |> prepare_grid()
    |> configure_cells()
  end

  def to_png(pgrid, cell_size \\ 10) do
    img_size = 2 * pgrid.rows * cell_size 

    img = ExPng.Image.new(img_size + 1, img_size + 1)
    center = trunc(img_size / 2)
    # IO.inspect(pgrid)

    Grid.each_cell(pgrid)
    |> Enum.reduce(img, fn cell, acc -> draw_cell(acc, pgrid, cell, cell_size, center) end) 
    |> ExPngExtensions.circle(center, center, pgrid.rows * cell_size, ExPng.Color.black())
  end

  def random_cell(pgrid) do
    rand_row = Enum.random(0..pgrid.rows - 1)
    rand_col = Enum.at(pgrid.cells, rand_row) |> length()

    get_cell(pgrid, rand_row, rand_col)
  end

  defp prepare_grid(pgrid) do
    rows = []
    row_count = pgrid.rows
    row_height = 1.0 / row_count
    rows = rows ++ [[PolarCell.initialize(0, 0)]]

    cells = Enum.reduce(1..(row_count - 1), rows, fn row, acc -> 
      radius = row / row_count
      circumference = 2 * :math.pi() * radius

      previous_count = Enum.at(acc, row - 1) |> length()
      estimated_width = circumference / previous_count
      ratio = (estimated_width / row_height) |> round()

      cells = previous_count * ratio
      r = Enum.map(0..cells - 1, fn col -> PolarCell.initialize(row, col) end) |> Enum.to_list()
      acc ++ [r]
    end)

    %PolarGrid{pgrid | cells: cells}
  end

  defp configure_cells(pgrid) do
    Grid.each_cell(pgrid)
    |> Enum.filter(fn c -> c != nil end)
    |> Enum.reduce(pgrid, fn cell, acc ->
      {row, col} = Cell.get_row_col(cell)

      if row > 0 do
        cell = get_cell(acc, row, col)
        cw = get_cell(acc, row, col + 1) |> Cell.get_row_col()
        ccw = get_cell(acc, row, col - 1) |> Cell.get_row_col()

        ratio = (Enum.at(acc.cells, row) |> length()) / (Enum.at(acc.cells, row - 1) |> length())
        parent = get_cell(acc, row - 1, trunc(col / ratio)) |> Cell.get_row_col()

        update_cell_with_neighbors(acc, cell, parent, cw, ccw)
      else 
        acc
      end
    end) 
  end

  defp update_cell_with_neighbors(pgrid, cell, parent, cw, ccw) do
    new_cell = get_cell(pgrid, cell.row, cell.col)
    |> PolarCell.update_neighbors(parent, cw, ccw)

    new_parent = get_cell(pgrid, parent)
    |> PolarCell.update_outward({cell.row, cell.col})
    # new_cell = Enum.at(grid.cells, row)
    # |> Enum.at(col)
    # |> Cell.update_neighbors(north, east, south, west)
    #
    # IO.inspect(new_cell)
    # IO.inspect(new_parent)
    update_grid_with_cells(pgrid, [new_cell, new_parent])
  end

  defp update_grid_with_cell(pgrid, cell) when cell == nil do
    pgrid
  end
  defp update_grid_with_cell(pgrid, cell) do
    new_col = Enum.at(pgrid.cells, cell.row)
    |> List.update_at(cell.col, fn _ -> cell end)

    new_cells = List.update_at(pgrid.cells, cell.row, fn _ -> new_col end)
    %PolarGrid{pgrid | cells: new_cells}
  end

  def update_grid_with_cells(pgrid, cells) do
    Enum.reduce(cells, pgrid, fn cell, acc -> update_grid_with_cell(acc, cell) end)
  end

  def get_cell(grid, row, col) when row < 0 or col < 0 or row >= grid.rows do
    nil
  end  
  def get_cell(grid, row, col) do
    case Enum.at(grid.cells, row) do
      nil -> nil
      cols -> Enum.at(cols, Integer.mod(col, (Enum.at(grid.cells, row) |> length())))
    end
  end
  def get_cell(grid, {row, col}) when row < 0 or col < 0 or row >= grid.rows do
    nil
  end
  def get_cell(grid, {row, col}) do
    case Enum.at(grid.cells, row) do
      nil -> nil
      cols -> Enum.at(cols, Integer.mod(col, (Enum.at(grid.cells, row) |> length())))
    end
  end

  defp draw_cell(img, _grid, cell, _cell_size, _center) when cell.row == 0 do
    img
  end
  defp draw_cell(img, grid, cell, cell_size, center) do
    theta = 2 * :math.pi() / (Enum.at(grid.cells, cell.row) |> length())
    inner_radius = cell.row * cell_size
    outer_radius = (cell.row + 1) * cell_size
    theta_ccw = cell.col * theta
    theta_cw = (cell.col + 1) * theta
    wall = ExPng.Color.black()

    ax = center + (inner_radius * :math.cos(theta_ccw)) |> trunc() 
    ay = center + (inner_radius * :math.sin(theta_ccw)) |> trunc() 
    _bx = center + (outer_radius * :math.cos(theta_ccw)) |> trunc() 
    _by = center + (outer_radius * :math.sin(theta_ccw)) |> trunc() 
    cx = center + (inner_radius * :math.cos(theta_cw)) |> trunc() 
    cy = center + (inner_radius * :math.sin(theta_cw)) |> trunc() 
    dx = center + (outer_radius * :math.cos(theta_cw)) |> trunc() 
    dy = center + (outer_radius * :math.sin(theta_cw)) |> trunc() 

    img = unless Cell.linked?(cell, cell.inward) do
      ExPngExtensions.line(img, {ax, ay}, {cx, cy}, wall)
    else
      img
    end
    img = unless Cell.linked?(cell, cell.cw) do
      ExPngExtensions.line(img, {cx, cy}, {dx, dy}, wall)
    else
      img
    end

    img
  end
end
