defmodule Speakeasy.Resolve do
  @moduledoc """
  Resolution middleware for Absinthe.

  See the [README](readme.html) for a complete example in a Absinthe Schema.
  """

  @behaviour Absinthe.Middleware

  @doc """
  The `Resolve` middleware will fetch a resource and mark the `Absinthe.Resolution` as resolved.

  It expects a return signature of: `{any | {:ok, any}, {:errors, any}`

  ## `Speakeasy.Resolve` has 4 forms:

  ### No arguments

    Providing no arguments to the callback will simply return the resource retreived by `Speakeasy.LoadResource` if it was called:

      field :post, type: :post do
        arg(:id, non_null(:string))
        middleware(Speakeasy.Authn)
        middleware(Speakeasy.LoadResourceByID, &Posts.get_post/1)
        middleware(Speakeasy.Authz, {Posts, :get_post})
        middleware(Speakeasy.Resolve)
      end

  ### 0 arity function

    Functions with an arity of 1 will receive the graph will receive the Absinthe arguments:

      field :post, type: :post do
        arg(:id, non_null(:string))
        middleware(Speakeasy.Authn)
        middleware(Speakeasy.LoadResourceByID, &Posts.get_post/1)
        middleware(Speakeasy.Authz, {Posts, :get_post})
        middleware(Speakeasy.Resolve, fn() -> MyApp.Posts.list_posts() end)
      end

  ### 1 arity function

    Functions with an arity of 1 will receive the graph will receive the Absinthe arguments:

      field :post, type: :post do
        arg(:id, non_null(:string))
        middleware(Speakeasy.Authn)
        middleware(Speakeasy.LoadResourceByID, &Posts.get_post/1)
        middleware(Speakeasy.Authz, {Posts, :get_post})
        middleware(Speakeasy.Resolve, fn(attrs) -> MyApp.Posts.something(attrs) end)
      end

  ### 2 arity function

    This is a good form to use when creating a resource if your code takes the `user` in additional to the attributes.

    Functions with an arity of 2 will receive the graph will receive the Absinthe arguments and the `SpeakEasy` current user:

      field :post, type: :post do
        arg(:id, non_null(:string))
        middleware(Speakeasy.Authn)
        middleware(Speakeasy.LoadResourceByID, &Posts.get_post/1)
        middleware(Speakeasy.Authz, {Posts, :get_post})
        middleware(Speakeasy.Resolve, fn(attrs, user) -> MyApp.Posts.create_post(attrs, user) end)
      end

  ### 3 arity function

    This is a good form to use when needing to update a resource.

    Functions with an arity of 3 will receive the graph will receive the resource retreived by `Speakeasy.LoadResource` (if it was called), the Absinthe arguments, and the `SpeakEasy` current user:

      field :post, type: :post do
        arg(:id, non_null(:string))
        middleware(Speakeasy.Authn)
        middleware(Speakeasy.LoadResourceByID, &Posts.get_post/1)
        middleware(Speakeasy.Authz, {Posts, :get_post})
        middleware(Speakeasy.Resolve, fn(resource, attrs, _user) -> MyApp.Posts.update_post(resource, attrs) end)
        # middleware(Speakeasy.Resolve, &MyApp.Posts.update_posts/3)
      end
  """
  def call(%{state: :unresolved} = res, fun) when is_function(fun) do
    call(res, resolver: fun)
  end

  def call(%{state: :unresolved} = res, opts) when is_list(opts) do
    call(res, Enum.into(opts, %{}))
  end

  def call(%{state: :unresolved, arguments: args} = res, %{resolver: fun})
      when is_function(fun, 0) do
    do_resolve(res, fun.())
  end

  def call(%{state: :unresolved, arguments: args} = res, %{resolver: fun})
      when is_function(fun, 1) do
    do_resolve(res, fun.(args))
  end

  def call(%{state: :unresolved, arguments: args, context: ctx} = res, %{resolver: fun})
      when is_function(fun, 2) do
    %{user: user} = ctx[:speakeasy]
    do_resolve(res, fun.(args, user))
  end

  def call(%{state: :unresolved, arguments: args, context: ctx} = res, %{resolver: fun})
      when is_function(fun, 3) do
    %{resource: resource, user: user} = ctx[:speakeasy]
    do_resolve(res, fun.(resource, args, user))
  end

  def call(%{state: :unresolved, context: %{speakeasy: ctx}} = res, _opts) do
    do_resolve(res, Map.get(ctx, :resource))
  end

  def call(res, _), do: res

  defp do_resolve(res, resources) when is_list(resources), do: %{res | state: :resolved, value: resources}

  defp do_resolve(res, {:ok, resource}), do: %{res | state: :resolved, value: resource}

  defp do_resolve(%{errors: errors} = res, {:error, reason}),
    do: %{res | state: :resolved, errors: [reason | errors]}

  defp do_resolve(res, value), do: %{res | state: :resolved, value: value}
end
