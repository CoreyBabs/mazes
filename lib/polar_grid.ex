defmodule PolarGrid do
  
  defstruct [:grid]

  def to_png(grid, cell_size \\ 10) do
    img_size = 2 * grid.rows * cell_size 

    img = ExPng.Image.new(img_size + 1, img_size + 1)
    center = trunc(img_size / 2)

    Grid.each_cell(grid)
    |> Enum.reduce(img, fn cell, acc -> draw_cell(acc, grid, cell, cell_size, center) end) 
    |> ExPngExtensions.circle(center, center, grid.rows * cell_size, ExPng.Color.black())
  end

  defp draw_cell(img, grid, cell, cell_size, center) do
    theta = 2 * :math.pi() / grid.cols
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

    img = unless Cell.linked?(cell, cell.north) do
      ExPngExtensions.line(img, {ax, ay}, {cx, cy}, wall)
    else
      img
    end
    img = unless Cell.linked?(cell, cell.east) do
      ExPngExtensions.line(img, {cx, cy}, {dx, dy}, wall)
    else
      img
    end

    img
  end
end
