defmodule Speakeasy.LoadResourceBy do
  @moduledoc """
  A convienence middleware to `LoadResource` using a specified key in the Absinthe arguments.

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
          arg(:blog_id, non_null(:string))
          arg(:name, non_null(:string))
          middleware(Speakeasy.Authn)
          middleware(Speakeasy.LoadResourceBy, {:blog_id, &MyApp.Blogs.get_blog/1})
          middleware(Speakeasy.Authz, {MyApp.Posts, :create_post})
          middleware(Speakeasy.Resolve, fn (blog, attrs, _user) -> MyApp.Posts.create_post(blog, attrs) end)

          # This is a shorthand of:
          # middleware(Speakeasy.LoadResource, fn(attrs) -> MyApp.Post.get_post(attrs[:id]))
        end
      end
  """
  @impl true
  def call(%{} = resolution, {key, fun}) when is_function(fun) do
    call(resolution, key: key, loader: fun)
  end

  def call(%{state: :unresolved, arguments: args} = resolution, opts) do
    value = Map.get(args, opts[:key])
    load_resource_by = fn -> opts[:loader].(value) end
    options = Keyword.merge(opts, loader: load_resource_by)
    LoadResource.call(resolution, options)
  end
end
