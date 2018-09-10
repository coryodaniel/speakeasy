defmodule Speakeasy.ResolveTest do
  use ExUnit.Case, async: true
  alias Speakeasy.Resolve

  def mock_resolution(identifier) do
    %{
      schema: SpeakeasyTest.Schema,
      definition: %{schema_node: %{identifier: identifier}},
      context: %{},
      arguments: %{},
      state: :unresolved,
      errors: [],
      value: nil
    }
  end

  def merge_context(%{context: old_context} = res, new_context) do
    merged_context = Map.merge(old_context, new_context)
    Map.put(res, :context, merged_context)
  end

  def with_resource(resolution), do: merge_context(resolution, %{speakeasy: %{resource: "kittens"}})
  def with_user(resolution), do: merge_context(resolution, %{current_user: "chauncy"})
  def with_args(resolution), do: Map.put(resolution, :arguments, %{id: 3, name: "foo"})

  test "returns the speakeasy resource from LoadResource if no arguments are provided" do
    resolution = :no_args |> mock_resolution |> with_resource
    %{state: state, value: value} = Resolve.call(resolution)
    assert state == :resolved
    assert value == "kittens"
  end

  test "calls the resolver with `arguments` when given a 1 arity function" do
    resolution = mock_resolution(:args) |> with_args
    resolver = fn(args) -> "Got #{args[:name]}" end

    %{state: state, value: value} = Resolve.call(resolution, resolver)
    assert state == :resolved
    assert value == "Got foo"
  end

  test "calls the resolver with `arguments` and `user` when given a 2 arity function" do
    resolution = mock_resolution(:args) |> with_args |> with_user
    resolver = fn(args, user) -> "Got #{user}'s #{args[:name]}" end

    %{state: state, value: value} = Resolve.call(resolution, resolver)
    assert state == :resolved
    assert value == "Got chauncy's foo"
  end

  test "calls the resolver with resource from LoadResource, `arguments` and `user` when given a 3 arity function" do
    resolution = mock_resolution(:args) |> with_args |> with_user |> with_resource
    resolver = fn(resource, args, user) -> "Got #{user}'s #{resource} and #{args[:name]}" end

    %{state: state, value: value} = Resolve.call(resolution, resolver)
    assert state == :resolved
    assert value == "Got chauncy's kittens and foo"
  end

  test "given an alternate user key, resolves the request" do
    resolution = mock_resolution(:args) |> with_args |> Map.put(:context, %{user: "chauncy"})
    resolver = fn(args, user) -> "Got #{user}'s #{args[:name]}" end

    %{state: state, value: value} = Resolve.call(resolution, resolver: resolver, user_key: :user)
    assert state == :resolved
    assert value == "Got chauncy's foo"
  end
end
