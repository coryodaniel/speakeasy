defmodule Speakeasy.LoadResource do
  @moduledoc """
  This middleware will take the result of this context and put it in ctx[:speakeasy][:resource]

  ## Examples
      middleware(Speakeasy.LoadResource, fn(attrs) -> &MyApp.get_album/1 end))
      middleware(Speakeasy.LoadResource, fn(attrs, user) -> &MyApp.get_album/2 end))
      middleware(Speakeasy.LoadResourceById, &MyApp.get_album/1) call LoadResource under the hood

  See the [README](readme.html) for usage.
  """

  @behaviour Absinthe.Middleware

  defmodule UnexpectedLoadingResponse do
    defexception [:message, :ref]
  end

  # @spec call(map(), fun() | keyword())
  @doc """
  Excepts a return of {:ok, resource} | {:error, reason}

  Throws:
  * UnexpectedLoadingResponse
  """
  def call(%{state: :unresolved} = res, fun) when is_function(fun), do: call(res, loader: fun)

  def call(%{state: :unresolved} = res, opts) when is_list(opts) do
    options = Enum.into(opts, %{user_key: Speakeasy.default_user_key()})
    call(res, options)
  end

  def call(%{state: :unresolved, arguments: args, context: ctx} = res, %{
        user_key: user_key,
        loader: loader
      }) do
    case get_resource(loader, args, ctx[user_key]) do
      %{} = resource -> Speakeasy.add_resource(res, resource)

      {:ok, resource} -> Speakeasy.add_resource(res, resource)

      {:error, reason} ->
        Absinthe.Resolution.put_result(
          res,
          {:error, reason}
        )

      ref ->
        raise UnexpectedLoadingResponse,
          message:
            "Unexpected response from LoadResource function. Expected `{:ok, resource}` | `{:error, reason}`",
          ref: ref
    end
  end

  def call(%{state: :unresolved}, %{}), do: raise(ArgumentError, message: "`:loader` is required")
  def call(res, _), do: res

  defp get_resource(fun, args, user) when is_function(fun, 2), do: fun.(args, user)
  defp get_resource(fun, args, _user) when is_function(fun, 1), do: fun.(args)
  defp get_resource(fun, _args, _user) when is_function(fun, 0), do: fun.()
end
