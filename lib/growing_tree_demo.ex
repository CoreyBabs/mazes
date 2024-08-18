defmodule GrowingTreeDemo do
 
  def demo() do
    run(&Enum.random/1, "./images/growing_tree_random.png")
    run(&last/1, "./images/growing_tree_last.png")
    run(&mix/1, "./images/growing_tree_mixed.png")
  end

  defp run(f, path) do
    grid = Grid.initialize(20, 20)
    start = Grid.random_cell(grid)

    GrowingTree.on(grid, start, f)
    |> Grid.to_png(10)
    |> ExPng.Image.to_file(path)
  end

  defp last(l) do
    Enum.at(l, -1)
  end

  defp mix(l) do
    if Enum.random(0..1) == 0 do
      Enum.at(l, -1)
    else
      Enum.random(l)
    end
  end

end
