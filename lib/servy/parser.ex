defmodule Servy.Parser do
  # alias Servy.Conv, as: Conv
  # is the same as since when not passing as
  # you get the last part of the name
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = String.split(top, "\r\n")

    [method, path, _] = String.split(request_line, " ")

    # call with parse_headers recursion
    headers = parse_headers(header_lines, %{})

    # call with parse_headers Enum.reduce
    # headers = parse_headers(header_lines)

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  # reduce with Enum.reduce
  # def parse_headers(headers_lines) do
  #   Enum.reduce(headers_lines, %{}, fn header, acc ->
  #     [key, value] = String.split(header, ": ")
  #     Map.put(acc, key, value)
  #   end)
  # end

  # reduce with recursion
  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    parse_headers(tail, Map.put(headers, key, value))
  end

  def parse_headers([], headers), do: headers

  @doc """
  Parses the given param string of the form `key1=value1&key2=value2` into a map with the corresponding keys and values

  ## Examples
      iex> params_string = "name=Baloo&type=Brown"
      iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
      %{"name" => "Baloo", "type" => "Brown"}
      iex>Servy.Parser.parse_params("multipart/form-data", params_string)
      %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end

  def parse_params(_content_type, _params_string), do: %{}
end
