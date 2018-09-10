defmodule Speakeasy.AuthnTest do
  use ExUnit.Case, async: true
  alias Speakeasy.Authn

  describe "default_error_message/0" do
    test "is configurable" do
      Application.put_env(:speakeasy, :authn_error_message, "nope")
      assert "nope" == Authn.default_error_message()
      Application.put_env(:speakeasy, :authn_error_message, :unauthenticated)
    end

    test "defaults to :unauthenticated" do
      assert :unauthenticated == Authn.default_error_message()
    end
  end

  test "authenticates and returns the resolution when there is a user context present" do
    resolution = %{
      context: %{
        current_user: "chauncy"
      },
      state: :unresolved
    }

    assert resolution == Authn.call(resolution)
  end

  test "given an alternate user key, authenticates and returns the resolution when there is a user context present" do
    resolution = %{
      context: %{
        user: "chauncy"
      },
      state: :unresolved
    }

    assert resolution == Authn.call(resolution, user_key: :user)
  end

  test "returns an ':unauthenticated' error when there is no user context" do
    resolution = %{context: %{}, errors: [], state: :unresolved}

    result = Authn.call(resolution)
    assert result == %{context: %{}, errors: [:unauthenticated], state: :resolved}
  end

  test "error message accepts a string" do
    resolution = %{context: %{}, errors: [], state: :unresolved}

    result = Authn.call(resolution, error_message: "nope")
    assert result == %{context: %{}, errors: ["nope"], state: :resolved}
  end

  test "error message accepts an arity 1 function" do
    resolution = %{context: %{}, errors: [], state: :unresolved}

    result = Authn.call(resolution, error_message: fn _resolution -> "nope!" end)
    assert result == %{context: %{}, errors: ["nope!"], state: :resolved}
  end
end
