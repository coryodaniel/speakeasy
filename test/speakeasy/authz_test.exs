defmodule Speakeasy.AuthzTest do
  use ExUnit.Case
  alias Speakeasy.Authz

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

  test "given an alternate user key, authenticates and returns the resolution when there is a user context present" do
    resolution = Map.put(mock_resolution(:alt_user_key), :context, %{user: "chauncy"})

    authorizer = {SpeakeasyTest.Post, :create_post}

    %{errors: errors, state: state} =
      Authz.call(resolution, user_key: :user, authorizer: authorizer)

    assert errors == ["No Chauncy's allowed"]
    assert state == :resolved
  end

  describe "support Bodyguard's authorize return values" do
    test "returns the resolution when the Bodyguard returns :ok" do
      resolution = mock_resolution(:create_post)

      result = Authz.call(resolution, {SpeakeasyTest.Post, :create_post})
      assert result == resolution
    end

    test "returns the resolution when the Bodyguard returns true" do
      resolution = mock_resolution(:list_posts)

      result = Authz.call(resolution, {SpeakeasyTest.Post, :list_posts})
      assert result == resolution
    end

    test "returns an 'unauthorized' resolution when the Bodyguard returns false" do
      resolution = mock_resolution(:update_post)

      result = Authz.call(resolution, {SpeakeasyTest.Post, :update_post})
      %{errors: errors, state: state} = result

      assert errors == [:unauthorized]
      assert state == :resolved
    end

    test "returns a resolution with the bodyguard error message when the Bodyguard returns an error tuple" do
      resolution = mock_resolution(:get_post)

      result = Authz.call(resolution, {SpeakeasyTest.Post, :get_post})
      %{errors: errors, state: state} = result

      assert errors == ["TOO BAD"]
      assert state == :resolved
    end
  end
end
