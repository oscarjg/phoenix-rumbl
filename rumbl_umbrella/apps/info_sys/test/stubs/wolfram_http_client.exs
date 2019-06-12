defmodule InfoSys.Stubs.WolframHttpClient do

  @wolfram_results_xml File.read!(__DIR__ <> "/../fixtures/wolfram_results.xml")
  @wolfram_empty_xml File.read!(__DIR__ <> "/../fixtures/wolfram_empty.xml")

  def request(url) do
    url = to_string(url)

    cond do
      String.contains?(url, "1+%2B+1") -> {:ok, {[], [], @wolfram_results_xml}}
      true -> {:ok, {[], [], @wolfram_empty_xml}}
    end
  end
end