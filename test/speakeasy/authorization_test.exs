defmodule Speakeasy.AuthorizationTest do
  use ExUnit.Case
  alias Speakeasy.Authorization

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

  describe "support Bodyguard's authorize return values" do
    test "returns the resolution when the Bodyguard returns :ok" do
      resolution = mock_resolution(:create_post)

      result = Authorization.call(resolution, %{})
      assert result == resolution
    end

    test "returns the resolution when the Bodyguard returns true" do
      resolution = mock_resolution(:update_post)

      result = Authorization.call(resolution, %{})
      assert result == resolution
    end

    test "returns an 'unauthorized' resolution when the Bodyguard returns false" do
      resolution = mock_resolution(:delete_post)

      result = Authorization.call(resolution, %{})
      %{errors: errors, state: state} = result

      assert errors == [:unauthorized]
      assert state == :resolved
    end

    test "returns a resolution with the bodyguard error message when the Bodyguard returns an error tuple" do
      resolution = mock_resolution(:list_post)

      result = Authorization.call(resolution, %{})
      %{errors: errors, state: state} = result

      assert errors == ["TOO BAD"]
      assert state == :resolved
    end
  end
end
