defmodule Speakeasy.AuthzTest do
  use ExUnit.Case
  alias Speakeasy.Authz

  def mock_resolution(user \\ "chauncy") do
    %Absinthe.Resolution{
      state: :unresolved,
      context: %{
        speakeasy: %Speakeasy.Context{user: user, resource: "kittens"}
      }
    }
  end

  test "given an alternate user key, authenticates and returns the resolution when there is a user context present" do
    resolution = mock_resolution("rupert")
    authorizer = {SpeakeasyTest.Post, :create_post}

    %{errors: errors, state: state} = Authz.call(resolution, authorizer: authorizer)

    assert errors == ["No Rupert's allowed"]
    assert state == :resolved
  end

  describe "support Bodyguard's authorize return values" do
    test "returns the resolution when the Bodyguard returns :ok" do
      resolution = mock_resolution()

      result = Authz.call(resolution, {SpeakeasyTest.Post, :create_post})
      assert result == resolution
    end

    test "returns the resolution when the Bodyguard returns true" do
      resolution = mock_resolution()

      result = Authz.call(resolution, {SpeakeasyTest.Post, :list_posts})
      assert result == resolution
    end

    test "returns an 'unauthorized' resolution when the Bodyguard returns false" do
      resolution = mock_resolution()

      result = Authz.call(resolution, {SpeakeasyTest.Post, :update_post})
      %{errors: errors, state: state} = result

      assert errors == [:unauthorized]
      assert state == :resolved
    end

    test "returns a resolution with the bodyguard error message when the Bodyguard returns an error tuple" do
      resolution = mock_resolution()

      result = Authz.call(resolution, {SpeakeasyTest.Post, :get_post})
      %{errors: errors, state: state} = result

      assert errors == ["TOO BAD"]
      assert state == :resolved
    end
  end
end
