defmodule Speakeasy.Authz do
  @moduledoc """
  Authorization middleware for Absinthe.

  Please see the [README](readme.html) for usage.

  middleware(Speakeasy.Authz, authorizer: Module.Name, message: fn(_ctx) -> "Error message" end, user_key: :x)
  middleware(Speakeasy.Authz, Module.Name)
  """

  @behaviour Absinthe.Middleware

  def call(%{state: :unresolved} = res, {m, f}), do: call(res, authorizer: {m, f})

  def call(%{state: :unresolved, context: ctx, arguments: args} = res, opts) when is_list(opts) do
    options = Enum.into(opts, %{user_key: Speakeasy.default_user_key()})
    call(res, options)
  end

  def call(%{state: :unresolved, context: ctx, arguments: args} = res, %{
        user_key: user_key,
        authorizer: {policy, action}
      }) do
    case Bodyguard.permit(policy, action, ctx[user_key], args) do
      :ok -> res
      {:error, reason} -> Absinthe.Resolution.put_result(res, {:error, reason})
    end
  end

  def call(%{state: :unresolved}, %{}),
    do: raise(ArgumentError, message: "`:authorizer` is required")

  def call(res, _), do: res
end
