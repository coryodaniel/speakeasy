defmodule Speakeasy.Authz do
  @moduledoc """
  Authorization middleware for Absinthe.

  Please see the [README](readme.html) for a complete example in a Absinthe Schema.

  middleware(Speakeasy.Authz, authorizer: Module.Name, message: fn(_ctx) -> "Error message" end)
  middleware(Speakeasy.Authz, Module.Name)
  """

  @behaviour Absinthe.Middleware

  def call(%{state: :unresolved} = res, {m, f}), do: call(res, authorizer: {m, f})

  def call(%{state: :unresolved} = res, opts) when is_list(opts) do
    options = Enum.into(opts, %{})
    call(res, options)
  end

  def call(%{state: :unresolved, context: %{speakeasy: speakeasy}} = res, %{
        authorizer: {policy, action}
      }) do
    resource_or_args = speakeasy.resource || res.arguments

    case Bodyguard.permit(policy, action, speakeasy.user, resource_or_args) do
      :ok -> res
      {:error, reason} -> Absinthe.Resolution.put_result(res, {:error, reason})
    end
  end

  def call(%{state: :unresolved}, %{}),
    do: raise(ArgumentError, message: "`:authorizer` is required")

  def call(res, _), do: res
end
