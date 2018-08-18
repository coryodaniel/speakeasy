defmodule Speakeasy do
  @moduledoc """
  Authorize Absinthe queries and mutations.

  Please see the [README](readme.html).
  """
  defmodule UnsupportedArityError do
    defexception [:message]

    @doc false
    def msg(mod, fun) do
      fun_name_without_arity = "#{mod}.#{fun}"

      "Speakeasy expects a function with an arity of 0-2. Implement one of: #{
        fun_name_without_arity
      }/2, #{fun_name_without_arity}/1, #{fun_name_without_arity}/0"
    end
  end

  @doc """
  If authorized returns an anonymous function that encapsulates your GraphQL resolution function.
  Otherwise returns the Bodyguard error response.

  ## Examples
      iex> Speakeasy.resolve(MyApp.Posts, :create_post)
  """
  def resolve(mod, fun) do
    fn _parent, args, res ->
      gql_context = res.context || %{}

      case Bodyguard.permit(mod, fun, gql_context, args) do
        :ok -> send(mod, fun, gql_context, args)
        :error -> {:error, "Unauthorized"}
        {:error, reason} -> {:error, reason}
      end
    end
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

  ## Examples
      iex> Speakeasy.resolve(MyApp.Posts, :create_post)
  """
  defmacro resolve!(mod, fun) do
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
          Speakeasy.resolve(unquote(mod), unquote(fun))
      end
    end
  end
end
