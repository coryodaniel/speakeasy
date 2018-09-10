defmodule Speakeasy.Authn do
  @moduledoc """
  Authentication middleware for Absinthe.

  It considers the context authenticated if the `user_key` is present in the Absinthe context.

  See the [README](readme.html) for usage.
  """

  @behaviour Absinthe.Middleware

  @doc """
  Update readme too...
  middleware(Speakeasy.Authn, message: fn(_ctx) -> "Error message" end, user_key: x)
  """
  def call(res), do: call(res, [])

  def call(%{state: :unresolved} = res, opts) do
    defaults = [user_key: Speakeasy.default_user_key(), error_message: default_error_message()]
    options = Keyword.merge(defaults, opts)

    case Map.has_key?(res.context, options[:user_key]) do
      true ->
        res

      _ ->
        Absinthe.Resolution.put_result(
          res,
          {:error, generate_message(options[:error_message], res)}
        )
    end
  end

  def call(res, _), do: res

  defp generate_message(msg, res) when is_function(msg), do: msg.(res)
  defp generate_message(msg, _), do: msg

  def default_error_message() do
    Application.get_env(:speakeasy, :authn_error_message)
  end
end
