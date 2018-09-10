defmodule Speakeasy.Context do
  defstruct [:resource, :user]

  def add_user(%Speakeasy.Context{} = ctx, user) do
    Map.put(ctx, :user, user)
  end

  def add_resource(%Speakeasy.Context{} = ctx, resource) do
    Map.put(ctx, :resource, resource)
  end
end
