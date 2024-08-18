defmodule EllersDemo do
  
  def demo() do
    Grid.initialize(5, 5)
    |> Ellers.on()
    |> IO.inspect()
    |> Grid.to_png(10)
    |> ExPng.Image.to_file("./images/ellers.png")
  end
end
