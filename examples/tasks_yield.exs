tasks =
  for i <- 1..10 do
    Task.async(fn ->
      Process.sleep(i * 1000)
      i
    end)
  end

tasks_with_results = Task.yield_many(tasks, 5000)

results =
  Enum.map(tasks_with_results, fn {task, res} ->
    # Shut down the tasks that did not reply nor exit
    IO.inspect(res)
    res || Task.shutdown(task, :brutal_kill)
  end)


# Here we are matching only on {:ok, value} and
# ignoring {:exit, _} (crashed tasks) and `nil` (no replies)
for {:ok, value} <- results do
  IO.inspect value
end

r = Enum.map([{:ok, %{res: 1}},{:ok, %{res: 2}}, nil, {:ok, %{res: 4}}, {:error, "reason"}], fn
  {:ok, res} -> res
  _ -> []
end)

IO.inspect(r)