defmodule Speakeasy.Authorization do
  @moduledoc """
  Authorization middleware for Absinthe schemas or fields.

  Please see the [README](readme.html) for usage.
  """

  @behaviour Absinthe.Middleware

  def call(%{state: :unresolved} = resolution, _config) do
    schema = resolution.schema
    identifier = resolution.definition.schema_node.identifier
    context = resolution.context
    args = resolution.arguments

    result = Bodyguard.permit(schema, identifier, context, args)

    case resolve_result(result) do
      :ok -> resolution
      {:error, reason} -> Absinthe.Resolution.put_result(resolution, {:error, reason})
    end
  end

  def call(resolution, _), do: resolution

  defp resolve_result(true), do: :ok
  defp resolve_result(:ok), do: :ok
  defp resolve_result(false), do: {:error, :unauthorized}
  defp resolve_result(:error), do: {:error, :unauthorized}
  defp resolve_result({:error, reason}), do: {:error, reason}
end
