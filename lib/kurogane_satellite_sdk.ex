defmodule KuroganeSatelliteSdk do
  @moduledoc """
  Public helpers for synthetic satellite and connector integrations.

  This SDK is part of the public technical ecosystem around Kurogane Hub. It
  does not expose or access the private Kurogane Hub production core.
  """

  alias KuroganeSatelliteSdk.Event

  @doc "Builds a normalized event map from public fields."
  def build_event(type, attrs) when is_atom(type) and is_map(attrs) do
    Event.new(type, attrs)
  end
end
