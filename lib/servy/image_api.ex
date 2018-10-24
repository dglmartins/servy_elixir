defmodule Servy.ImageApi do
  def get_image_url(image_path) do
    case query(image_path) do
      {:ok, image_url} ->
        image_url

      {:error, reason} ->
        "Whoops! #{reason}"
    end
  end

  def api_url(id) do
    "https://api.myjson.com/bins/#{URI.encode(id)}"
  end

  def query(id) do
    api_url(id)
    |> HTTPoison.get()
    |> handle_response
  end

  def handle_response({:ok, %{status_code: 200, body: body}}) do
    image_url =
      body
      |> Poison.Parser.parse!(%{})
      |> get_in(["image", "image_url"])

    {:ok, image_url}
  end

  def handle_response({:ok, %{status_code: status, body: body}}) do
    message =
      body
      |> Poison.Parser.parse!(%{})
      |> get_in(["message"])

    {:error, message}
  end

  def handle_response({:error, %{reason: reason}}) do
    {:error, reason}
  end
end
