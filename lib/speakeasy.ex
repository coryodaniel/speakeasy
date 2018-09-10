defmodule Speakeasy do
  @moduledoc """
  Authorize Absinthe queries and mutations.

  Please see the [README](readme.html).
  """

  @spec add_user(%Absinthe.Resolution{}, any()) :: %Absinthe.Resolution{}
  def add_user(resolution, user) do
    res =
      resolution
      |> init_resolution

    context = res.context
    speakeasy_ctx = Speakeasy.Context.add_user(context[:speakeasy], user)

    updated_context = Map.put(context, :speakeasy, speakeasy_ctx)
    Map.put(res, :context, updated_context)
  end

  @spec add_resource(%Absinthe.Resolution{}, any()) :: %Absinthe.Resolution{}
  def add_resource(resolution, resource) do
    res =
      resolution
      |> init_resolution

    context = res.context
    speakeasy_ctx = Speakeasy.Context.add_resource(context[:speakeasy], resource)

    updated_context = Map.put(context, :speakeasy, speakeasy_ctx)
    Map.put(res, :context, updated_context)
  end

  def default_user_key() do
    Application.get_env(:speakeasy, :user_key)
  end

  defp init_resolution(%{context: %{speakeasy: _}} = res), do: res
  defp init_resolution(%{context: context} = res) do
    updated_context = Map.put(context, :speakeasy, %Speakeasy.Context{})
    Map.put(res, :context, updated_context)
  end
  defp init_resolution(res) do
    res
    |> Map.put(:context, %{})
    |> init_resolution
  end
end
