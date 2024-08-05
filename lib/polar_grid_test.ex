defmodule PolarGridTest do
  def test() do
    Grid.initialize(8, 8)
    |> PolarGrid.to_png(10)
    |> ExPng.Image.to_file("./images/polar.png")
  end
end
