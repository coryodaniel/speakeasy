defmodule Speakeasy.Context do
  @moduledoc """
  Speakeasy current context. Consists of a `:resource` and a `:user`
  """
  defstruct [:resource, :user]

  @doc """
  Adds a user to the `Speakeasy.Context`

  ## Examples
      iex> Speakeasy.Context.add_user(%Absinthe.Resolution{}, "chauncy")
      %Absinthe.Resolution{context: %{speakeasy: %Speakeasy.Context{user: "chauncy", resource: nil}}}

      iex> Speakeasy.Context.add_user(%Speakeasy.Context{}, "chauncy")
      %Speakeasy.Context{user: "chauncy", resource: nil}
  """
  @spec add_user(%Absinthe.Resolution{} | %Speakeasy.Context{}, any()) ::
          %Absinthe.Resolution{} | %Speakeasy.Context{}
  def add_user(%Speakeasy.Context{} = ctx, user), do: Map.put(ctx, :user, user)

  def add_user(%Absinthe.Resolution{} = resolution, user) do
    res =
      resolution
      |> init_resolution

    context = res.context
    speakeasy_ctx = Speakeasy.Context.add_user(context[:speakeasy], user)

    updated_context = Map.put(context, :speakeasy, speakeasy_ctx)
    Map.put(res, :context, updated_context)
  end

  @doc """
  Adds a resource to the `Speakeasy.Context`

  ## Examples
      iex> Speakeasy.Context.add_resource(%Absinthe.Resolution{}, "kittens")
      %Absinthe.Resolution{context: %{speakeasy: %Speakeasy.Context{user: nil, resource: "kittens"}}}

      iex> Speakeasy.Context.add_resource(%Speakeasy.Context{}, "kittens")
      %Speakeasy.Context{user: nil, resource: "kittens"}
  """
  @spec add_resource(%Absinthe.Resolution{} | %Speakeasy.Context{}, any()) ::
          %Absinthe.Resolution{} | %Speakeasy.Context{}
  def add_resource(%Speakeasy.Context{} = ctx, resource), do: Map.put(ctx, :resource, resource)

  def add_resource(%Absinthe.Resolution{} = resolution, resource) do
    res =
      resolution
      |> init_resolution

    context = res.context
    speakeasy_ctx = Speakeasy.Context.add_resource(context[:speakeasy], resource)

    updated_context = Map.put(context, :speakeasy, speakeasy_ctx)
    Map.put(res, :context, updated_context)
  end

  @spec init_resolution(%Absinthe.Resolution{}) :: %Absinthe.Resolution{}
  defp init_resolution(%{context: %{speakeasy: %Speakeasy.Context{}}} = res), do: res

  defp init_resolution(%{context: context} = res) when is_map(context) do
    updated_context = Map.put(context, :speakeasy, %Speakeasy.Context{})
    Map.put(res, :context, updated_context)
  end

  defp init_resolution(%{context: context} = res) when is_nil(context) do
    res
    |> Map.put(:context, %{})
    |> init_resolution
  end
end
