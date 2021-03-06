defmodule Servy.FourOhFourCounter do
  use GenServer

  @process_name :four_oh_four_counter

  def start_link(_arg) do
    IO.puts("Starting the 404 counter...")
    GenServer.start_link(__MODULE__, %{}, name: @process_name)
  end

  def bump_count(path) do
    GenServer.call(@process_name, {:bump_count, path})
  end

  def get_count(path) do
    GenServer.call(@process_name, {:get_count, path})
  end

  def get_counts() do
    GenServer.call(@process_name, :get_counts)
  end

  def reset() do
    GenServer.cast(@process_name, :reset)
  end

  # Server Callbacks

  def handle_call({:bump_count, path}, _from, state) do
    new_state = Map.update(state, path, 1, &(&1 + 1))
    {:reply, :ok, new_state}
  end

  def handle_call({:get_count, path}, _from, state) do
    count = Map.get(state, path, 0)
    {:reply, count, state}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:reset, _state) do
    {:noreply, %{}}
  end
end
