defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "accepts a request on a socket and sends back a response" do
    spawn(HttpServer, :start, [4000])

    url1 = "http://localhost:4000/wildthings"
    url2 = "http://localhost:4000/bears"
    url3 = "http://localhost:4000/about"

    [url1, url2, url3]
    |> Enum.map(&Task.async(fn -> HTTPoison.get(&1) end))
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_successful_response/1)
  end

  defp assert_successful_response({:ok, response}) do
    assert response.status_code == 200
  end
end

# max_concurrent_requests = 5
#
# for _ <- 1..max_concurrent_requests do
#   Task.async(arg1)
#   spawn(fn ->
#     {:ok, response} = HTTPoison.get("http://localhost:4000/wildthings")
#
#     send(parent, {:ok, response})
#   end)
# end

# for _ <- 1..max_concurrent_requests do
#   receive do
#     {:ok, response} ->
#       assert response.status_code == 200
#       assert response.body == "Bears, Lions, Tigers"
#   end
# end
#   request = """
#   GET /wildthings HTTP/1.1\r
#   Host: example.com\r
#   User-Agent: ExampleBrowser/1.0\r
#   Accept: */*\r
#   \r
#   """
#
#   response = HttpClient.send_request(request)
#
#   assert response = """
#          HTTP/1.1 200 OK\r
#          Content-Type: text/html\r
#          Content-Length: 20\r
#          \r
#          Bears, Lions, Tigers
#          """
