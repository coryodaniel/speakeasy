defmodule Speakeasy.ResolutionHelper do
  def mock_resolution(identifier) do
    %{
      schema: SpeakeasyTest.Schema,
      definition: %{
        schema_node: %{
          identifier: identifier
        }
      },
      context: %{},
      arguments: %{},
      state: :unresolved,
      errors: []
    }
  end

  def merge_context(%{context: old_context} = res, new_context) do
    merged_context = Map.merge(old_context, new_context)
    Map.put(res, :context, merged_context)
  end

  def with_user(resolution) do
    merge_context(resolution, %{current_user: "chauncy"})
  end

  def with_speakeasy_context(resolution, ctx) do
    merge_context(resolution, %{speakeasy: ctx})
  end
  
  def with_resource(resolution),
    do: merge_context(resolution, %{speakeasy: %Speakeasy.Context{resource: "kittens"}})
end
