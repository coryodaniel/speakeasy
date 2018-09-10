defmodule Speakeasy.LoadResourceByID do
  @moduledoc """
  A convienence middleware to `LoadResource` using the `:id` in the Absinthe arguments.

  See the [README](readme.html) for a complete example in a Absinthe Schema.
  """

  @behaviour Absinthe.Middleware
  alias Speakeasy.LoadResource

  @doc """
  This calls `LoadResource` under the hood and extracts the `:id` out of the arguments map.

  ## Examples
      object :post_mutations do
        @desc "Create post"
        field :create_post, type: :post do
          arg(:name, non_null(:string))
          middleware(Speakeasy.Authn)
          middleware(Speakeasy.LoadResourceByID, &MyApp.Posts.get_post/1)

          # This is a shorthand of:
          # middleware(Speakeasy.LoadResource, fn(attrs) -> MyApp.Post.get_post(attrs[:id]))
        end
      end
  """
  @impl true
  def call(%{} = resolution, fun) when is_function(fun) do
    call(resolution, loader: fun)
  end

  def call(%{state: :unresolved, arguments: %{id: id}} = resolution, opts) do
    load_resource_by_id = fn -> opts[:loader].(id) end
    options = Keyword.merge(opts, loader: load_resource_by_id)
    LoadResource.call(resolution, options)
  end
end
