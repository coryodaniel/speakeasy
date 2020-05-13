defmodule Speakeasy.LoadResourcePassParentTest do
  use ExUnit.Case, async: true
  alias Speakeasy.LoadResourcePassParent

  def mock_resolution(source) do
    %Absinthe.Resolution{
      state: :unresolved,
      source: source,
      context: %{
        current_user: "chauncy",
        speakeasy: %Speakeasy.Context{
          user: "chauncy"
        }
      }
    }
  end

  test "updates the resolution's context with the parent" do
    source = %{one: "two", three: [:four]}
    resolution = mock_resolution(source)

    %{context: %{speakeasy: context}} = LoadResourcePassParent.call(resolution, [])
    assert context == %Speakeasy.Context{resource: source, user: "chauncy"}
  end
end
