defmodule SpeakeasyTest do
  use ExUnit.Case

  def absinthe_args() do
    %{
      parent: nil,
      args: %{"hello" => "world"},
      resolution: %{
        context: %{
          current_user: "chauncy"
        }
      }
    }
  end

  test "sends arguments and user when the function has an arity of 2 and the user_key is provided" do
    resolver = Speakeasy.resolve(SpeakeasyTest.Post, :method_expecting_user, user_key: :current_user)
    %{parent: parent, args: args, resolution: resolution} = absinthe_args()

    result = resolver.(parent, args, resolution)
    assert result.function == "method_expecting_user/2"
    assert result.args == args
    assert result.user == resolution.context.current_user
  end

  test "sends arguments and context when the function has an arity of 2" do
    resolver = Speakeasy.resolve(SpeakeasyTest.Post, :create_post)
    %{parent: parent, args: args, resolution: resolution} = absinthe_args()

    result = resolver.(parent, args, resolution)
    assert result.function == "create_post/2"
    assert result.args == args
    assert result.context == resolution.context
  end

  test "sends arguments when the function has an arity of 1" do
    resolver = Speakeasy.resolve(SpeakeasyTest.Post, :update_post)
    %{parent: parent, args: args, resolution: resolution} = absinthe_args()

    result = resolver.(parent, args, resolution)
    assert result.function == "update_post/1"
    assert result.args == args
    refute Map.has_key?(result, :context)
  end

  test "sends no arguments when the function has an arity of 0" do
    resolver = Speakeasy.resolve(SpeakeasyTest.Post, :list_posts)
    %{parent: parent, args: args, resolution: resolution} = absinthe_args()

    result = resolver.(parent, args, resolution)
    assert result.function == "list_posts/0"
    refute Map.has_key?(result, :args)
    refute Map.has_key?(result, :context)
  end

  test "ends resolution and returns an authorization error when Bodyguard does not permit the operation" do
    resolver = Speakeasy.resolve(SpeakeasyTest.Post, :delete_post)
    %{parent: parent, args: args, resolution: resolution} = absinthe_args()

    result = resolver.(parent, args, resolution)
    assert result == {:error, :unauthorized}
  end

  describe "Speakeasy.UnsupportedArityError" do
    test "msg/2 outputs supported function names" do
      msg = Speakeasy.UnsupportedArityError.msg(IO, :puts)
      assert String.contains?(msg, "IO.puts/2")
      assert String.contains?(msg, "IO.puts/1")
      assert String.contains?(msg, "IO.puts/0")
    end
  end
end
