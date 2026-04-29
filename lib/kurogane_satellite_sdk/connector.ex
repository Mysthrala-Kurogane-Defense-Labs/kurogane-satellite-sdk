defmodule KuroganeSatelliteSdk.Connector do
  @moduledoc "Behaviour for public synthetic connector examples."

  @callback source_name() :: String.t()
  @callback poll() :: {:ok, [map()]} | {:error, term()}
end
