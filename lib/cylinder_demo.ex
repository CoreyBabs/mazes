defmodule CylinderDemo do
  
  def demo() do
    CylinderGrid.initialize(7, 16)
    |> RecursiveBacktracker.on()
    |> Grid.to_png(10)
    |> ExPng.Image.to_file("./images/cylinder.png")
  end
end
