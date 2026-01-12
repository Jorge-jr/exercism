defmodule Bowling do
  @moduledoc """
  Bowling game scoring module.
  """

  @spec start() :: map()
  def start, do: %{rolls: []}

  @spec roll(map(), integer()) :: {:ok, map()} | {:error, String.t()}
  def roll(%{rolls: rolls} = game, pins) when is_integer(pins) do
    with :ok <- validate_pin_count(pins),
         :ok <- validate_game_not_complete(rolls),
         :ok <- validate_frame_pins(rolls, pins) do
      {:ok, %{game | rolls: rolls ++ [pins]}}
    end
  end

  @spec score(map()) :: {:ok, integer()} | {:error, String.t()}
  def score(%{rolls: rolls}) do
    if game_complete?(rolls) do
      {:ok, calculate_score(rolls)}
    else
      {:error, "Score cannot be taken until the end of the game"}
    end
  end

  defp validate_pin_count(pins) when pins < 0,
    do: {:error, "Negative roll is invalid"}
  
  defp validate_pin_count(pins) when pins > 10,
    do: {:error, "Pin count exceeds pins on the lane"}
  
  defp validate_pin_count(_pins), do: :ok

  defp validate_game_not_complete(rolls) do
    if game_complete?(rolls) do
      {:error, "Cannot roll after game is over"}
    else
      :ok
    end
  end

  defp validate_frame_pins(rolls, pins) do
    frames = build_frames(rolls)
    frame_number = length(frames)

    cond do
      frame_number == 0 -> :ok
      frame_number < 10 -> validate_regular_frame(List.last(frames), pins)
      frame_number == 10 -> validate_tenth_frame(List.last(frames), pins)
      true -> :ok
    end
  end

  defp validate_regular_frame([10], _pins), do: :ok  # Strike - new frame starts
  defp validate_regular_frame([a], pins) when a + pins > 10,
    do: {:error, "Pin count exceeds pins on the lane"}
  defp validate_regular_frame(_frame, _pins), do: :ok
  defp validate_tenth_frame([10, b], pins) when b < 10 and b + pins > 10,
    do: {:error, "Pin count exceeds pins on the lane"}
  defp validate_tenth_frame(_frame, _pins), do: :ok

  defp calculate_score(rolls), do: score_frames(rolls, 1, 0)

  defp score_frames(_rolls, frame, total) when frame > 10, do: total
  defp score_frames([10 | rest], frame, total) do
    bonus = rest |> Enum.take(2) |> Enum.sum()
    score_frames(rest, frame + 1, total + 10 + bonus)
  end

  defp score_frames([a, b | rest], frame, total) when a + b == 10 do
    bonus = List.first(rest) || 0
    score_frames(rest, frame + 1, total + 10 + bonus)
  end

  defp score_frames([a, b | rest], frame, total) do
    score_frames(rest, frame + 1, total + a + b)
  end

  defp score_frames(_rolls, _frame, total), do: total

  defp game_complete?(rolls) do
    frames = build_frames(rolls)
    length(frames) == 10 and tenth_frame_complete?(List.last(frames))
  end

  defp tenth_frame_complete?([10, _b, _c]), do: true
  defp tenth_frame_complete?([a, b, _c]) when a + b == 10, do: true
  defp tenth_frame_complete?([a, b]) when a + b < 10, do: true
  defp tenth_frame_complete?(_), do: false


  defp build_frames(rolls), do: build_frames(rolls, [], 1)
  defp build_frames([], acc, _frame), do: Enum.reverse(acc)

  defp build_frames([10 | rest], acc, frame) when frame < 10 do
    build_frames(rest, [[10] | acc], frame + 1)
  end

  defp build_frames([a, b | rest], acc, frame) when frame < 10 do
    build_frames(rest, [[a, b] | acc], frame + 1)
  end

  defp build_frames([a], acc, frame) when frame < 10 do
    build_frames([], [[a] | acc], frame + 1)
  end

  defp build_frames(rolls, acc, 10) do
    Enum.reverse([rolls | acc])
  end
end