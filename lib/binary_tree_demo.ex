defmodule BinaryTreeDemo do
  def demo() do
    Grid.initialize(4, 4)
    |> BinaryTree.on()
    |> Grid.to_string()
    |> IO.puts()
  end
end
