defmodule Speakeasy.LoadResourceTest do
  use ExUnit.Case, async: true
  alias Speakeasy.LoadResource

  def mock_resolution() do
    %Absinthe.Resolution{
      state: :unresolved,
      arguments: %{id: "3", name: "foo"},
      context: %{
        current_user: "chauncy",
        speakeasy: %Speakeasy.Context{
          user: "chauncy"
        }
      }
    }
  end

  describe "when receiving a 1 arity function" do
    test "updates the resolution's context with the results of loader.(args)" do
      resolution = mock_resolution()

      loader = fn attrs ->
        {:ok, attrs[:name]}
      end

      %{context: %{speakeasy: context}} = LoadResource.call(resolution, loader)
      assert context == %Speakeasy.Context{resource: "foo", user: "chauncy"}
    end
  end

  describe "when receiving a 2 arity function" do
    test "updates the resolution's context with the results of loader.(args, user)" do
      resolution = mock_resolution()

      loader = fn attrs, user -> {:ok, "#{user}'s #{attrs[:name]}"} end

      %{context: %{speakeasy: context}} = LoadResource.call(resolution, loader)
      assert context == %Speakeasy.Context{resource: "chauncy's foo", user: "chauncy"}
    end
  end
end
