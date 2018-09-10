defmodule Speakeasy.ResolveTest do
  use ExUnit.Case, async: true
  alias Speakeasy.Resolve

  def mock_resolution() do
    %Absinthe.Resolution{
      schema: SpeakeasyTest.Schema,
      definition: %{schema_node: %{identifier: "mock"}},
      context: %{
        speakeasy: %Speakeasy.Context{
          user: "chauncy",
          resource: "kittens"
        }
      },
      arguments: %{id: 3, name: "foo"},
      state: :unresolved,
      errors: [],
      value: nil
    }
  end

  test "returns the speakeasy resource from LoadResource if no options are provided" do
    resolution = mock_resolution()
    %{state: state, value: value} = Resolve.call(resolution, [])
    assert state == :resolved
    assert value == "kittens"
  end

  test "calls the resolver with `arguments` when given a 1 arity function" do
    resolution = mock_resolution()
    resolver = fn args -> "Got #{args[:name]}" end

    %{state: state, value: value} = Resolve.call(resolution, resolver)
    assert state == :resolved
    assert value == "Got foo"
  end

  test "calls the resolver with `arguments` and `user` when given a 2 arity function" do
    resolution = mock_resolution()
    resolver = fn args, user -> "Got #{user}'s #{args[:name]}" end

    %{state: state, value: value} = Resolve.call(resolution, resolver)
    assert state == :resolved
    assert value == "Got chauncy's foo"
  end

  test "calls the resolver with resource from LoadResource, `arguments` and `user` when given a 3 arity function" do
    resolution = mock_resolution()
    resolver = fn resource, args, user -> "Got #{user}'s #{resource} and #{args[:name]}" end

    %{state: state, value: value} = Resolve.call(resolution, resolver)
    assert state == :resolved
    assert value == "Got chauncy's kittens and foo"
  end
end
