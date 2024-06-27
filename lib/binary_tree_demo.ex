defmodule BinaryTreeDemo do
  def demo() do
    Grid.initialize(4, 4)
    |> BinaryTree.on()
    |> Grid.to_string()
    |> IO.puts()
  end

  def demo_image() do
    Grid.initialize(4, 4)
    |> BinaryTree.on()
    |> Grid.to_png(10)
    |> ExPng.Image.to_file("./images/binary_tree.png")
  end

  def demo_both() do
    grid = Grid.initialize(4, 4)
    |> BinaryTree.on()

    Grid.to_string(grid)
    |> IO.puts()

    Grid.to_png(grid, 10)
    |> ExPng.Image.to_file("./images/binary_tree.png")
  end

  def demo_color() do
    grid = Grid.initialize(25, 25)
    |> BinaryTree.on()

    start_x = Float.floor(grid.cols / 2) |> trunc()
    start_y = Float.floor(grid.rows / 2) |> trunc()
    start = Grid.get_cell(grid, start_x, start_y)
    distances = Grid.distances_from_cell(grid, start)
    {_f, max} = Distances.max(distances)

    Grid.to_png_with_color(grid, 1, distances, max)
    |> ExPng.Image.to_file("./images/binary_tree.png")
  end
end
