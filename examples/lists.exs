query = "Foo"
backends = ["Wolfram", "Google", "Boing"]

defmodule Cache do
    def fetch(backend, _key) do
        case backend do
            "Wolfram" -> {:ok, [%{foo: "bar", backend: backend}, %{foo: "bar 2", backend: backend}]}
            "Google" -> :error
            "Boing" -> {:ok, %{}}
        end

    end
end

{uncached_backends, results} =
  Enum.reduce(
    backends,
    {[], []},
    fn backend, {uncached_backends, acc_results} ->
      case Cache.fetch(backend, query) do
        {:ok, results} -> {uncached_backends, [results | acc_results]}
        :error -> {[backend | uncached_backends], acc_results}
      end
    end)

IO.inspect(uncached_backends)
IO.inspect(List.flatten(results))
IO.inspect(results)