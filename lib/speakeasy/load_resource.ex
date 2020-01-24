defmodule Speakeasy.LoadResource do
  @moduledoc """
  Loads a resource into the speakeasy context:

  ```
  %Absinthe.Resolution{context: %{speakeasy: %Speakeasy.Context{resource: your_resource}}}
  ```

  See the [README](readme.html) for a complete example in a Absinthe Schema.
  """

  @behaviour Absinthe.Middleware

  defmodule UnexpectedLoadingResponse do
    defexception [:message, :ref]
  end

  @doc """

  Handles loading a resource or resources and storing them in the `Speakeasy.Context` for later resolving.

  Callback functions must return a type of: `any | {:ok, any} | {:error, error} | nil`. It is effectively looking for the return signatures of Phoenix Contexts.

  ## Examples
    Loading a resource with a 1-arity function will receive the Absinthe arguments:

      object :post_mutations do
        @desc "Create post"
        field :create_post, type: :post do
          arg(:name, non_null(:string))
          middleware(Speakeasy.Authn)
          middleware(Speakeasy.LoadResource, fn(attrs) -> MyApp.Posts.create_post(attrs) end)
        end
      end

    Loading a resource with a 2-arity function will receive the Absinthe arguments and the `SpeakEasy` current user:

      object :post_mutations do
        @desc "Create post"
        field :create_post, type: :post do
          arg(:name, non_null(:string))
          middleware(Speakeasy.Authn)
          middleware(Speakeasy.LoadResource, fn(attrs, user) -> MyApp.Posts.create_post(attrs, user) end)
        end
      end
  """
  @impl true
  def call(%{state: :unresolved} = res, fun) when is_function(fun), do: call(res, loader: fun)

  def call(%{state: :unresolved} = res, opts) when is_list(opts) do
    options = Enum.into(opts, %{})
    call(res, options)
  end

  def call(%{state: :unresolved, arguments: args, context: ctx} = res, %{loader: loader}) do
    case get_resource(loader, args, ctx[:speakeasy].user, ctx) do
      %{} = resource ->
        Speakeasy.Context.add_resource(res, resource)

      {:ok, resource} ->
        Speakeasy.Context.add_resource(res, resource)

      {:error, reason} ->
        Absinthe.Resolution.put_result(res, {:error, reason})

      nil ->
        Absinthe.Resolution.put_result(res, {:error, :not_found})

      ref ->
        raise UnexpectedLoadingResponse,
          message:
            "Unexpected response from LoadResource function. Expected `{:ok, resource}` | `{:error, reason}`",
          ref: ref
    end
  end

  def call(%{state: :unresolved}, %{}), do: raise(ArgumentError, message: "`:loader` is required")
  def call(res, _), do: res

  defp get_resource(fun, args, user, ctx) when is_function(fun, 3), do: fun.(args, user, ctx)
  defp get_resource(fun, args, user, _ctx) when is_function(fun, 2), do: fun.(args, user)
  defp get_resource(fun, args, _user, _ctx) when is_function(fun, 1), do: fun.(args)
  defp get_resource(fun, _args, _user, _ctx) when is_function(fun, 0), do: fun.()
end
