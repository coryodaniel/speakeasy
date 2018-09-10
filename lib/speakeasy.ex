defmodule Speakeasy do
  @moduledoc """
  Authorize Absinthe queries and mutations.

  Please see the [README](readme.html).
  """

  @doc false
  def default_user_key() do
    Application.get_env(:speakeasy, :user_key)
  end
end
