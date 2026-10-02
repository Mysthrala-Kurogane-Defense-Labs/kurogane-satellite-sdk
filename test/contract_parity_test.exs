defmodule ContractParityTest do
  use ExUnit.Case, async: true
  {vectors, _} = Code.eval_file("../fixtures/contract_vectors.exs", __DIR__)

  for vector <- vectors do
    @vector vector
    test @vector["name"] do
      if @vector["valid"] do
        assert :ok = KuroganeSatelliteSdk.Event.validate(@vector["event"])
        assert {:ok, wire} = KuroganeSatelliteSdk.Event.to_wire(@vector["event"])
        assert wire == @vector["event"]
      else
        assert {:error, _} = KuroganeSatelliteSdk.Event.validate(@vector["event"])
      end
    end
  end
end
