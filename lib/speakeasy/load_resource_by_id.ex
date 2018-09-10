defmodule Speakeasy.LoadResourceByID do
  @moduledoc """
  A convienence middleware to `LoadResource` using the `id` in the Absinthe arguments.

  This calls `LoadResource` under the hood
  ## Examples

      middleware(Speakeasy.LoadResourceById, &MyApp.get_album/1)

  See the [README](readme.html) for usage.
  """

  @behaviour Absinthe.Middleware
  alias Speakeasy.LoadResource

  def call(%{} = resolution, fun) when is_function(fun) do
    call(resolution, loader: fun)
  end

  def call(%{state: :unresolved, arguments: %{id: id}} = resolution, opts) do
    load_resource_by_id = fn -> opts[:loader].(id) end
    options = Keyword.merge(opts, loader: load_resource_by_id)
    LoadResource.call(resolution, options)
  end
end
