defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  test "it caches only the most recent pledges and totals their amound" do
    PledgeServer.start()

    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("curly", 30)
    PledgeServer.create_pledge("daisy", 40)
    PledgeServer.create_pledge("grace", 50)

    cache_pledges = PledgeServer.recent_pledges()
    expected_cache = [{"grace", 50}, {"daisy", 40}, {"curly", 30}]

    total_pledged = PledgeServer.total_pledged()

    assert cache_pledges == expected_cache
    assert(total_pledged == 120)
  end
end
