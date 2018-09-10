defmodule Speakeasy.Resolve do
  @moduledoc """
  Resolution middleware for Absinthe.

  See the [README](readme.html) for usage.
  """

  @behaviour Absinthe.Middleware

  @doc """
  Update readme too...

  middleware(Speakeasy.Resolve) #=> {:ok, ctx[:speakeasy][:resource]}
  middleware(Speakeasy.Resolve, fn(params) -> MyContext.whatever end)
  middleware(Speakeasy.Resolve, fn(params, user) -> MyContext.whatever end)
  middleware(Speakeasy.Resolve, fn(resource, params, user \\ nil) -> end)
  middleware(Speakeasy.Resolve, &Albums.update_albums/3)
  """
  def call(%{state: :unresolved} = res, fun) when is_function(fun) do
    call(res, user_key: Speakeasy.default_user_key(), resolver: fun)
  end

  def call(%{state: :unresolved} = res, opts) when is_list(opts) do
    call(res, Enum.into(opts, %{}))
  end

  def call(%{state: :unresolved, arguments: args} = res, %{resolver: fun, user_key: user_key})
      when is_function(fun, 1) do
    do_resolve(res, fun.(args))
  end

  def call(%{state: :unresolved, arguments: args, context: ctx} = res, %{
        resolver: fun,
        user_key: user_key
      })
      when is_function(fun, 2) do
    do_resolve(res, fun.(args, ctx[user_key]))
  end

  def call(%{state: :unresolved, arguments: args, context: ctx} = res, %{
        resolver: fun,
        user_key: user_key
      })
      when is_function(fun, 3) do
    %{resource: resource} = ctx[:speakeasy]
    do_resolve(res, fun.(resource, args, ctx[user_key]))
  end

  def call(%{state: :unresolved, context: %{speakeasy: ctx}} = res, _opts) do
    do_resolve(res, Map.get(ctx, :resource))
  end

  def call(res, _), do: res

  defp do_resolve(res, {:ok, resource}), do: %{res | state: :resolved, value: resource}
  defp do_resolve(%{errors: errors} = res, {:error, reason}), do: %{res | state: :resolved, errors: [reason | errors]}
  defp do_resolve(res, value), do: %{res | state: :resolved, value: value}
end
