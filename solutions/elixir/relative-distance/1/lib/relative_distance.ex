defmodule RelativeDistance do
  @doc """
  Find the degree of separation of two members given a family tree.
  Returns the number of hops between them or nil if no connection exists.
  """
  @spec degree_of_separation(
          %{String.t() => [String.t()]},
          String.t(),
          String.t()
        ) :: nil | non_neg_integer()
  def degree_of_separation(family_tree, person_a, person_b) do
    network_map = build_graph(family_tree)

    cond do
      not Map.has_key?(network_map, person_a) -> nil
      not Map.has_key?(network_map, person_b) -> nil
      person_a == person_b -> 0
      true -> bfs_distance(network_map, person_a, person_b)
    end
  end

  defp build_graph(tree) do
    people =
      tree
      |> Enum.flat_map(fn {parent, children} -> [parent | children] end)
      |> Enum.uniq()

    base =
      Enum.reduce(people, %{}, fn p, acc ->
        Map.put(acc, p, [])
      end)

    base
    |> add_parent_child_edges(tree)
    |> add_sibling_edges(tree)
  end

  defp add_parent_child_edges(graph, tree) do
    Enum.reduce(tree, graph, fn {parent, children}, acc ->
      acc =
        Map.update!(acc, parent, fn existing ->
          Enum.uniq(existing ++ children)
        end)

      Enum.reduce(children, acc, fn child, g ->
        Map.update!(g, child, fn existing ->
          Enum.uniq(existing ++ [parent])
        end)
      end)
    end)
  end

  defp add_sibling_edges(graph, tree) do
    Enum.reduce(tree, graph, fn {_parent, children}, acc ->
      Enum.reduce(children, acc, fn child, g ->
        others = Enum.reject(children, & &1 == child)

        Map.update!(g, child, fn existing ->
          existing
          |> Enum.concat(others)
          |> Enum.uniq()
        end)
      end)
    end)
  end

  defp bfs_distance(graph, start, goal) do
    bfs(graph, [{start, 0}], MapSet.new([start]), goal)
  end

  defp bfs(_graph, [], _visited, _goal), do: nil

  defp bfs(_graph, [{node, dist} | _], _visited, node), do: dist

  defp bfs(graph, [{node, dist} | queue], visited, goal) do
    neighbors =
      graph
      |> Map.get(node, [])
      |> Enum.reject(&MapSet.member?(visited, &1))

    visited = Enum.reduce(neighbors, visited, &MapSet.put(&2, &1))

    new_queue =
      queue ++ Enum.map(neighbors, fn n -> {n, dist + 1} end)

    bfs(graph, new_queue, visited, goal)
  end
end
