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
end
