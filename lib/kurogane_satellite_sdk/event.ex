defmodule KuroganeSatelliteSdk.Event do
  @moduledoc """
  Public 0.2 event contract for synthetic labs. Known string keys are normalized
  without creating atoms. Extensions must be JSON-compatible values.
  """

  @types [:asset, :alarm, :telemetry]
  @common [:event_id, :occurred_at, :site_id, :asset_id]
  @fields [:type | @common] ++ [:name, :asset_type, :severity, :message, :metric, :value, :unit]
  @timestamp ~r/^(?!0000)\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:[0-5]\d(?:\.\d{1,6})?(?:Z|[+-]\d{2}:\d{2})$/

  def new(type, attrs) when is_map(attrs) do
    with {:ok, type} <- event_type(type),
         {:ok, attrs} <- normalize_keys(attrs),
         :ok <- matching_type(attrs, type) do
      normalize(Map.put(attrs, :type, type))
    end
  end

  def new(_, _), do: {:error, :invalid_event}

  def normalize(event) when is_map(event) do
    with {:ok, event} <- normalize_keys(event),
         {:ok, type} <- event_type(Map.get(event, :type)),
         event = Map.put(event, :type, type),
         :ok <- validate_fields(event),
         true <- json_value?(Map.delete(event, :type)) do
      {:ok, event}
    else
      false -> {:error, :non_json_value}
      error -> error
    end
  end

  def normalize(_), do: {:error, :invalid_event}

  def validate(event) do
    case normalize(event) do
      {:ok, _} -> :ok
      error -> error
    end
  end

  @doc "Returns string-keyed data; it does not encode or transmit JSON."
  def to_wire(event) do
    with {:ok, event} <- normalize(event) do
      {:ok, event |> Map.put(:type, Atom.to_string(event.type)) |> wire_value()}
    end
  end

  defp normalize_keys(event) do
    collision =
      Enum.find(@fields, fn key ->
        Map.has_key?(event, key) and Map.has_key?(event, Atom.to_string(key)) and
          event[key] != event[Atom.to_string(key)]
      end)

    if collision do
      {:error, {:conflicting_field, collision}}
    else
      {:ok,
       Enum.reduce(@fields, event, fn key, acc ->
         string = Atom.to_string(key)

         case Map.fetch(acc, string) do
           {:ok, value} -> acc |> Map.delete(string) |> Map.put(key, value)
           :error -> acc
         end
       end)}
    end
  end

  defp event_type(type) when type in @types, do: {:ok, type}
  defp event_type("asset"), do: {:ok, :asset}
  defp event_type("alarm"), do: {:ok, :alarm}
  defp event_type("telemetry"), do: {:ok, :telemetry}
  defp event_type(_), do: {:error, :unsupported_event_type}

  defp matching_type(attrs, type) do
    if Map.has_key?(attrs, :type) do
      case event_type(attrs.type) do
        {:ok, ^type} -> :ok
        _ -> {:error, {:conflicting_field, :type}}
      end
    else
      :ok
    end
  end

  defp validate_fields(event) do
    required = @common ++ required_for(event.type)
    missing = Enum.reject(required, &Map.has_key?(event, &1))

    invalid =
      Enum.filter(@fields -- [:type], fn key ->
        Map.has_key?(event, key) and not valid_field?(key, event[key])
      end)

    cond do
      missing != [] -> {:error, {:missing_fields, missing}}
      invalid != [] -> {:error, {:invalid_fields, invalid}}
      true -> :ok
    end
  end

  defp required_for(:asset), do: [:name]
  defp required_for(:alarm), do: [:severity, :message]
  defp required_for(:telemetry), do: [:metric, :value]

  defp valid_field?(:occurred_at, value) when is_binary(value) do
    String.valid?(value) and Regex.match?(@timestamp, value) and
      match?({:ok, _, _}, DateTime.from_iso8601(calendar_timestamp(value)))
  end

  defp valid_field?(:occurred_at, _), do: false
  defp valid_field?(:value, value), do: is_number(value)
  defp valid_field?(:severity, value), do: value in ["info", "warning", "critical"]

  defp valid_field?(_, value),
    do: is_binary(value) and String.valid?(value) and String.trim(value) != ""

  # RFC 3339 -00:00 describes a known UTC instant with unknown local offset.
  # Elixir rejects that spelling; normalize only the calendar-check input.
  # The event and wire output retain the original timestamp and its semantics.
  defp calendar_timestamp(value), do: String.replace_suffix(value, "-00:00", "Z")

  defp json_value?(value) when is_binary(value), do: String.valid?(value)
  defp json_value?(value) when is_number(value) or is_boolean(value) or is_nil(value), do: true
  defp json_value?([]), do: true
  defp json_value?([head | tail]), do: json_value?(head) and is_list(tail) and json_value?(tail)
  defp json_value?(%{__struct__: _}), do: false

  defp json_value?(value) when is_map(value) do
    keys = Enum.map(Map.keys(value), &wire_key/1)

    Enum.all?(keys, &is_binary/1) and Enum.uniq(keys) == keys and
      Enum.all?(value, fn {_, item} -> json_value?(item) end)
  end

  defp json_value?(_), do: false

  defp wire_key(key) when is_atom(key), do: Atom.to_string(key)
  defp wire_key(key) when is_binary(key), do: if(String.valid?(key), do: key, else: nil)
  defp wire_key(_), do: nil

  defp wire_value(value) when is_map(value),
    do: Map.new(value, fn {key, item} -> {wire_key(key), wire_value(item)} end)

  defp wire_value(value) when is_list(value), do: Enum.map(value, &wire_value/1)
  defp wire_value(value), do: value
end
