defmodule Servy.GenericServerTwo do
  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, callback_module)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state, callback_module)
    end
  end
end

defmodule Servy.FourOhFourCounter do
  alias Servy.GenericServerTwo

  @process_name :four_oh_four_counter

  def start() do
    IO.puts("Starting the 404 counter...")
    GenericServerTwo.start(__MODULE__, %{}, @process_name)
  end

  def bump_count(path) do
    GenericServerTwo.call(@process_name, {:bump_count, path})
  end

  def get_count(path) do
    GenericServerTwo.call(@process_name, {:get_count, path})
  end

  def get_counts() do
    GenericServerTwo.call(@process_name, :get_counts)
  end

  def reset() do
    GenericServerTwo.cast(@process_name, :reset)
  end

  def handle_call({:bump_count, path}, state) do
    new_state = Map.update(state, path, 1, &(&1 + 1))
    {:ok, new_state}
  end

  def handle_call({:get_count, path}, state) do
    count = Map.get(state, path, 0)
    {count, state}
  end

  def handle_call(:get_counts, state) do
    {state, state}
  end

  def handle_cast(:reset, state) do
    %{}
  end
end
