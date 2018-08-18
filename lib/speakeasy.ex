defmodule Speakeasy do
  @moduledoc """
  Authorize Absinthe queries and mutations.

  Please see the [README](readme.html).
  """

  @doc """
  If authorized returns an anonymous function that encapsulates your GraphQL resolution function.
  Otherwise returns the Bodyguard error response.

  See [this](readme.html#speakeasy-resolve-2-or-speakeasy-resolve-2) section of the README for usage examples.
  
  ## Examples
      iex> Speakeasy.resolve(MyApp.Posts, :create_post)

      iex> Speakeasy.resolve(MyApp.Posts, :create_post, user_key: :current_user)


  """
  @spec resolve(module(), atom(), keyword(atom())) :: function() | :error | {:error, String.t}
  def resolve(mod, fun, opts \\ []) do
    fn _parent, args, res ->
      gql_context = res.context || %{}
      case Bodyguard.permit(mod, fun, gql_context, args) do
        :ok ->
          ctx = context_or_user(gql_context, opts)
          send(mod, fun, ctx, args)
        :error -> {:error, "Unauthorized"}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  defp context_or_user(gql_context, []), do: gql_context
  defp context_or_user(gql_context, [user_key: user_key]) do
    Map.get(gql_context, user_key) || gql_context
  end

  defp send(mod, fun, context, args) do
    cond do
      :erlang.function_exported(mod, fun, 2) ->
        apply(mod, fun, [args, context])

      :erlang.function_exported(mod, fun, 1) ->
        apply(mod, fun, [args])

      :erlang.function_exported(mod, fun, 0) ->
        apply(mod, fun, [])

      true ->
        raise Speakeasy.UnsupportedArityError,
          message: Speakeasy.UnsupportedArityError.msg(mod, fun)
    end
  end

  @doc """
  Macro form of `resolve/2`. This will cause your application to fail to compile if your
  resolution function isn't compatible with what Speakeasy

  This function works the same as `resolve/2`
  """
  defmacro resolve!(mod, fun, opts \\ []) do
    quote do
      max_arity =
        :functions
        |> unquote(mod).__info__
        |> Keyword.get_values(unquote(fun))
        |> Enum.sort()
        |> List.last()

      cond do
        max_arity > 2 ->
          raise Speakeasy.UnsupportedArityError,
            message: Speakeasy.UnsupportedArityError.msg(unquote(mod), unquote(fun))

        max_arity == nil ->
          raise Speakeasy.UnsupportedArityError,
            message: Speakeasy.UnsupportedArityError.msg(unquote(mod), unquote(fun))

        true ->
          Speakeasy.resolve(unquote(mod), unquote(fun), unquote(opts))
      end
    end
  end
end
