defmodule WeaveMaze do
  def demo() do
    WeaveGrid.initialize(20, 20)
    |> RecursiveBacktracker.on()
    |> WeaveGrid.to_png(10, 0.1)
    |> ExPng.Image.to_file("./images/weaved.png")
  end
end
