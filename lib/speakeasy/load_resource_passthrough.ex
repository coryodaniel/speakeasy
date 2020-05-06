defmodule Speakeasy.LoadResourcePassParent do
  @moduledoc """
  A convienence middleware to `LoadResource` using the parent in the Absinthe resolver.

  See the [README](readme.html) for a complete example in a Absinthe Schema.
  """
  @behaviour Absinthe.Middleware
  alias Speakeasy.LoadResource

  @doc """
  This calls `LoadResource` under the hood and extracts the resource from the parent.

  ## Examples
      object :user do
        field :id, non_null(:id)
        field :name, :string
        field :private_things, :secret_data do
          middleware(Speakeasy.Authn)
          middleware(Speakeasy.LoadResourcePassParent)
          middleware(Speakeasy.Authz, {Users, :read_private_things})
          middleware(Speakeasy.Resolve, fn user, _, _ -> {:ok, user.private_things} end)
        end
      end
  """
  @impl true
  def call(%{source: parent} = resolution, _opts) do
    LoadResource.call(resolution, loader: fn -> {:ok, parent} end)
  end
end