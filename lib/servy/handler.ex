defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests"

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam
  import Servy.View, only: [render: 3]
  alias Servy.FourOhFourCounter, as: Counter

  # this defines a module attribute, so pages_path is now a constant that can be used anywhere in the module
  @pages_path Path.expand("../../pages", __DIR__)

  # the numbers in the import statment below refer to the airity of the function, so this imports all rewrite_paths that have airity of 1, so all of them

  # import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1, emojify: 1]

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @doc "Transforms requests into responses."
  def handle(request) do
    request
    |> parse
    |> rewrite_path()
    # |> log()
    |> route()
    # |> emojify()
    |> track()
    |> put_content_length()
    |> format_response()
  end

  # def route(conv) do
  #   route(conv, conv.method, conv.path)
  # end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges/new"} = conv) do
    Servy.PledgeController.new(conv)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    %{snapshots: snapshots, location: where_is_bigfoot} = Servy.SensorServer.get_sensor_data()

    render(conv, "sensors.html.eex", snapshots: snapshots, location: where_is_bigfoot)

    # %{conv | status: 200, resp_body: inspect(sensor_data)}
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer() |> :timer.sleep()

    %{conv | status: 200, resp_body: "Awake!"}
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> page} = conv) do
    @pages_path
    |> Path.join("#{page}.html")
    |> File.read()
    |> handle_file(conv)
  end

  # name=Baloo&type=Brown
  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    # params = %{"name" => "Baloo", "type" => "Brown"}
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    # params = %{"name" => "Baloo", "type" => "Brown"}
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/api/jobs"} = conv) do
    # params = %{"name" => "Baloo", "type" => "Brown"}
    Servy.Api.JobsController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/faq"} = conv) do
    @pages_path
    |> Path.join("faq.md")
    |> File.read()
    |> handle_file(conv)
    |> markdown_to_html
  end

  # def route(%Conv{method: "GET", path: "/about"} = conv) do
  #   file =
  #     Path.expand("../../pages", __DIR__)
  #     |> Path.join("about.html")
  #
  #   case File.read(file) do
  #     {:ok, content} ->
  #       %{conv | status: 200, resp_body: content}
  #
  #     {:error, :enoent} ->
  #       %{conv | status: 404, resp_body: "File not found!"}
  #
  #     {:error, reason} ->
  #       %{conv | status: 500, resp_body: "File error #{reason}"}
  #   end
  # end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    BearController.delete(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/404s"} = conv) do
    counts = Counter.get_counts()
    %{conv | status: 200, resp_body: inspect(counts)}
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def put_content_length(conv) do
    headers = Map.put(conv.resp_headers, "Content-Length", byte_size(conv.resp_body))
    %{conv | resp_headers: headers}
  end

  def markdown_to_html(%Conv{status: 200} = conv) do
    markdown = Earmark.as_html(conv.resp_body)

    case markdown do
      {:ok, content, []} ->
        %{conv | resp_body: content}

      _ ->
        conv
    end
  end

  def markdown_to_html(%Conv{} = conv), do: conv

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_headers["Content-Type"]}\r
    Content-Length: #{conv.resp_headers["Content-Length"]}\r
    \r
    #{conv.resp_body}
    """
  end
end
