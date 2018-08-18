defmodule Speakeasy.Authentication do
  @moduledoc """
  Authentication middleware for Absinthe schemas or fields.

  It considers the context authenticated if the `user_key` is present.

  Please see the [README](readme.html) for usage.
  """

  @behaviour Absinthe.Middleware

  def call(%{state: :unresolved} = resolution, opts) do
    options = Keyword.merge([user_key: :current_user], opts)
    case Map.has_key?(resolution.context, options[:user_key]) do
      true ->
        resolution

      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "unauthenticated"})
    end
  end

  def call(resolution, _), do: resolution
end
