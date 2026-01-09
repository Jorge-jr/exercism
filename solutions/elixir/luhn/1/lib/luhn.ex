defmodule Luhn do
  @spec valid?(String.t()) :: boolean
  def valid?(number) when is_binary(number) do
    number =
      number
      |> String.replace(" ", "")

    cond do
      byte_size(number) < 2 ->
        false

      number =~ ~r/^\d+$/ ->
        number
        |> String.graphemes()
        |> Enum.map(&String.to_integer/1)
        |> Enum.reverse()
        |> Enum.with_index()
        |> Enum.map(fn
          {digit, index} when rem(index, 2) == 1 -> double_and_fix(digit)
          {digit, _index} -> digit
        end)
        |> Enum.sum()
        |> rem(10) == 0

      true ->
        false
    end
  end

  defp double_and_fix(digit) when digit < 5, do: digit * 2
  defp double_and_fix(digit), do: digit * 2 - 9
end
