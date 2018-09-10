defmodule SpeakeasyTest do
  use ExUnit.Case, async: true

  describe "default_user_key/0" do
    test "is configurable" do
      Application.put_env(:speakeasy, :user_key, :user)
      assert :user == Speakeasy.default_user_key()
      Application.put_env(:speakeasy, :user_key, :current_user)
    end

    test "defaults to :current_user" do
      assert :current_user == Speakeasy.default_user_key()
    end
  end
end
