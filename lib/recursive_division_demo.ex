defmodule RecursiveDivisionDemo do
  
  def demo() do
    Grid.initialize(20, 20)
    |> RecursiveDivision.on()
    |> Grid.to_png(10)
    |> ExPng.Image.to_file("./images/recursive_division.png") 
  end
end
