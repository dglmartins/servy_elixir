defmodule Servy.Parser do
  # alias Servy.Conv, as: Conv
  # is the same as since when not passing as
  # you get the last part of the name
  alias Servy.Conv

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %Conv{
      method: method,
      path: path
    }
  end
end
