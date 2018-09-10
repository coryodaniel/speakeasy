defmodule Speakeasy do
  @moduledoc """
  Authorize Absinthe queries and mutations.

  Please see the [README](readme.html).
  """

  defp context_or_user(gql_context, :user),
    do: context_or_user(gql_context, user_key: :current_user)

  defp context_or_user(gql_context, []), do: gql_context

  defp context_or_user(gql_context, user_key: user_key) do
    Map.get(gql_context, user_key) || nil
  end

  def default_user_key() do
    Application.get_env(:speakeasy, :user_key)
  end
end
