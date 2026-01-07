defmodule JigsawPuzzle do
  @doc """
  Fill in missing jigsaw puzzle details from partial data
  """
  @type format() :: :landscape | :portrait | :square
  @type t() :: %__MODULE__{
          pieces: pos_integer() | nil,
          rows: pos_integer() | nil,
          columns: pos_integer() | nil,
          format: format() | nil,
          aspect_ratio: float() | nil,
          border: pos_integer() | nil,
          inside: pos_integer() | nil
        }
  defstruct [:pieces, :rows, :columns, :format, :aspect_ratio, :border, :inside]
  
  @spec data(jigsaw_puzzle :: JigsawPuzzle.t()) ::
          {:ok, JigsawPuzzle.t()} | {:error, String.t()}
  def data(jigsaw_puzzle) do
    case compute_rows_and_columns(jigsaw_puzzle) do
      {:error} -> {:error, "Insufficient data"}
      puzzle -> compute_by_rows_and_columns(puzzle)
    end
  end
  
  defp compute_rows_and_columns(%JigsawPuzzle{columns: columns, rows: rows} = puzzle)
      when columns != nil and rows != nil do
    puzzle
  end
  
  defp compute_rows_and_columns(%JigsawPuzzle{pieces: pieces, aspect_ratio: aspect} = puzzle) 
      when pieces != nil and aspect != nil do
    rows = trunc(:math.sqrt(pieces / aspect))
    columns = trunc(rows * aspect)
    %{puzzle | rows: rows, columns: columns}
  end
  
  defp compute_rows_and_columns(%JigsawPuzzle{columns: columns, aspect_ratio: aspect, format: format} = puzzle)
      when columns != nil and (format == :square or aspect == 1) do
    %{puzzle | rows: columns}
  end
  
  defp compute_rows_and_columns(%JigsawPuzzle{rows: rows, aspect_ratio: aspect, format: format} = puzzle)
      when rows != nil and (format == :square or aspect == 1) do
    %{puzzle | columns: rows}
  end
  
  defp compute_rows_and_columns(%JigsawPuzzle{format: format, aspect_ratio: aspect, inside: inside} = puzzle)
      when inside != nil and (format == :square or aspect == 1) do
    rows = trunc(:math.sqrt(inside)) + 2
    %{puzzle | columns: rows, rows: rows}
  end
  
  defp compute_rows_and_columns(%JigsawPuzzle{rows: rows, aspect_ratio: aspect} = puzzle) 
      when aspect != nil and aspect > 1 and rows != nil do
    columns = trunc(rows * aspect)
    %{puzzle | columns: columns}
  end
  
  defp compute_rows_and_columns(%JigsawPuzzle{pieces: pieces, format: format, border: border} = puzzle) 
      when pieces != nil and border != nil and format != nil do
    sum = (border + 4) / 2
    product = pieces
    discriminant = sum * sum - 4 * product
    
    if discriminant >= 0 do
      sqrt_disc = :math.sqrt(discriminant)
      r1 = (sum + sqrt_disc) / 2
      r2 = (sum - sqrt_disc) / 2
      
      {rows, columns} = case format do
        :portrait -> {trunc(r1), trunc(r2)}  # rows > columns
        :landscape -> {trunc(r2), trunc(r1)} # columns > rows
        :square -> {trunc(r1), trunc(r2)}
      end
      
      %{puzzle | rows: rows, columns: columns}
    else
      {:error}
    end
  end
  
  defp compute_rows_and_columns(_), do: {:error}
  
  defp compute_format(%JigsawPuzzle{format: format} = puzzle) when format != nil, do: format
  defp compute_format(%JigsawPuzzle{aspect_ratio: aspect}) when aspect > 1, do: :landscape
  defp compute_format(%JigsawPuzzle{aspect_ratio: aspect}) when aspect == 1, do: :square
  defp compute_format(%JigsawPuzzle{rows: rows, columns: columns}) when rows > columns, do: :portrait
  defp compute_format(%JigsawPuzzle{rows: rows, columns: columns}) when rows < columns, do: :landscape
  defp compute_format(%JigsawPuzzle{rows: rows, columns: columns}) when rows == columns, do: :square
  defp compute_format(_), do: nil
  
  defp compute_aspect_ratio(%JigsawPuzzle{aspect_ratio: aspect}) when aspect != nil, do: aspect
  defp compute_aspect_ratio(%JigsawPuzzle{rows: rows, columns: columns}) when rows != nil and columns != nil do
    columns / rows
  end
  defp compute_aspect_ratio(_), do: nil
  
  defp compute_by_rows_and_columns(%JigsawPuzzle{columns: columns, rows: rows} = puzzle) 
      when columns != nil and rows != nil do
    pieces = rows * columns
    border = 2 * (rows + columns) - 4
    inside = pieces - border
    aspect = compute_aspect_ratio(puzzle)
    format = compute_format(puzzle)
    
    # Validate contradictory data
    cond do
      puzzle.format != nil and puzzle.format != format ->
        {:error, "Contradictory data"}
      puzzle.pieces != nil and puzzle.pieces != pieces ->
        {:error, "Contradictory data"}
      puzzle.border != nil and puzzle.border != border ->
        {:error, "Contradictory data"}
      puzzle.inside != nil and puzzle.inside != inside ->
        {:error, "Contradictory data"}
      puzzle.aspect_ratio != nil and abs(puzzle.aspect_ratio - aspect) > 0.01 ->
        {:error, "Contradictory data"}
        puzzle.rows != puzzle.columns and puzzle.format == :square -> 
        {:error, "Contradictory data"}
      true ->
        {:ok,
         %{puzzle
           | rows: rows,
             columns: columns,
             border: border,
             inside: inside,
             pieces: pieces,
             aspect_ratio: aspect,
             format: format}}
    end
  end
  
  defp compute_by_rows_and_columns({:error}), do: {:error, "Insufficient data"}
end