defmodule Mask do

  defstruct [:rows, :cols, :bits]

  def initialize(rows, cols) do
    bits = Enum.map(0..(rows - 1), fn _row ->
      Enum.map(0..(cols - 1), fn _col ->
        true
      end)
    end)

    %Mask{rows: rows, cols: cols, bits: bits}
  end

  def get(mask, row, col) 
    when row < 0 or col < 0 or row >= mask.rows or col >= mask.cols do
    false
  end  
  def get(mask, row, col) do
    case Enum.at(mask.bits, row) do
      nil -> false
      cols -> Enum.at(cols, col)
    end
  end
  def get(mask, {row, col})
    when row < 0 or col < 0 or row >= mask.rows or col >= mask.cols do
    false
  end
  def get(mask, {row, col}) do
    case Enum.at(mask.bits, row) do
      nil -> false
      cols -> Enum.at(cols, col)
    end
  end

  def set(mask, row, col, is_on) do
    new_col = Enum.at(mask.bits, row)
    |> List.update_at(col, fn _ -> is_on end)

    new_bits = List.update_at(mask.bits, row, fn _ -> new_col end)
    %Mask{mask | bits: new_bits}
  end

  def count(mask) do
    each_bit(mask)
    |> Enum.reduce(0, fn b, acc ->
      if b do
        acc + 1
      else
        acc
      end
    end)
  end

  def each_row(mask) do
    Enum.map(mask.bits, fn row -> row end)
  end

  def each_bit(mask) do
    each_row(mask)
    |> Enum.flat_map(fn col -> col end)
  end

  def random_location(mask) do
    row = Enum.random(0..(mask.rows - 1)) 
    col = Enum.random(0..(mask.cols - 1))
    case get(mask, row, col) do
      true -> {row, col}
      false -> random_location(mask)
    end
  end

  def from_txt(file) do
    lines = File.read!(file)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> String.trim(line) end)

    rows = length(lines)
    cols = Enum.at(lines, 0) |> String.length()
    mask = initialize(rows, cols)
    
    Enum.reduce(0..rows - 1, mask, fn row, acc ->
      Enum.reduce(0..cols - 1, acc, fn col, acc_m ->
        char = Enum.at(lines, row) |> String.at(col)  
        set(acc_m, row, col, char != "X")
      end)
    end) 
  end

  def from_png(file) do
    {:ok, image} = ExPng.Image.from_file(file)
    mask = initialize(image.width, image.height)

    Enum.reduce(0..mask.rows - 1, mask, fn row, acc ->
      Enum.reduce(0..mask.cols - 1, acc, fn col, acc_m ->
        pixel = ExPng.Image.at(image, {col, row})  
        set(acc_m, row, col, pixel != ExPng.Color.black())
      end)
    end) 

  end
end
