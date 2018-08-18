defmodule Speakeasy.Middleware.AuthenticationTest do
  use ExUnit.Case

  test "authenticates and returns the resolution when there is a user context present" do
    resolution = %{
      context: %{
        current_user: "chauncy"
      }
    }

    assert resolution == Speakeasy.Middleware.Authentication.call(resolution)
  end

  test "given an alternate user key, authenticates and returns the resolution when there is a user context present" do
    resolution = %{
      context: %{
        user: "chauncy"
      }
    }

    assert resolution == Speakeasy.Middleware.Authentication.call(resolution, :user)
  end

  test "returns an 'unauthorized' error when there is no user context" do
    resolution = %{context: %{}, errors: [], state: :pending}

    result = Speakeasy.Middleware.Authentication.call(resolution)
    assert result == %{context: %{}, errors: ["unauthenticated"], state: :resolved}
  end
end
