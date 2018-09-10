defmodule Speakeasy.LoadResourceTest do
  use ExUnit.Case, async: true
  alias Speakeasy.LoadResource

  describe "when receiving a 1 arity function" do
    test "updates the resolution's context with the results of loader.(args)" do
      resolution = %{
        context: %{},
        state: :unresolved,
        arguments: %{"id" => "3", "name" => "foo"}
      }

      loader = fn attrs -> {:ok, attrs["name"]} end

      %{context: %{speakeasy: context}} = LoadResource.call(resolution, loader)
      assert context == %Speakeasy.Context{resource: "foo"}
    end
  end

  describe "when receiving a 2 arity function" do
    test "updates the resolution's context with the results of loader.(args, user)" do
      resolution = %{
        context: %{
          current_user: "chauncy"
        },
        state: :unresolved,
        arguments: %{id: "3", name: "foo"}
      }

      loader = fn attrs, user -> {:ok, "#{user}'s #{attrs[:name]}"} end

      %{context: %{speakeasy: context}} = LoadResource.call(resolution, loader)
      assert context == %Speakeasy.Context{resource: "chauncy's foo"}
    end

    test "updates the resolution's context with the results of loader.(args, user) when the user is under a different key" do
      resolution = %{
        context: %{
          user: "chauncy"
        },
        state: :unresolved,
        arguments: %{id: "3", name: "foo"}
      }

      loader = fn attrs, user -> {:ok, "#{user}'s #{attrs[:name]}"} end

      %{context: %{speakeasy: context}} = LoadResource.call(resolution, loader: loader, user_key: :user)
      assert context == %Speakeasy.Context{resource: "chauncy's foo"}
    end
  end
end
