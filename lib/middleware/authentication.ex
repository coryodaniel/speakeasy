defmodule Speakeasy.Middleware.Authentication do
  @moduledoc """
  Authentication middleware for Absinthe schemas or fields.

  It considers the context authenticated if the `user_key` is present.

  Please see the [README](readme.html) for usage.
  """

  @behaviour Absinthe.Middleware

  def call(resolution, user_key \\ :current_user) do
    case Map.has_key?(resolution.context, user_key) do
      true ->
        resolution

      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "unauthenticated"})
    end
  end
end
