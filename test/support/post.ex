defmodule SpeakeasyTest.Post do
  def authorize(:create_post, _, _), do: :ok
  def authorize(:update_post, _, _), do: :ok
  def authorize(:list_posts, _, _), do: :ok
  def authorize(:delete_post, _, _), do: :error
  def authorize(:method_expecting_user, _, _), do: :ok

  def method_expecting_user(post, user) do
    %{
      function: "method_expecting_user/2",
      args: post,
      user: user
    }
  end

  def create_post(post, context) do
    %{
      function: "create_post/2",
      args: post,
      context: context
    }
  end

  def update_post(post) do
    %{
      function: "update_post/1",
      args: post
    }
  end

  def list_posts() do
    %{
      function: "list_posts/0"
    }
  end

  def delete_post(_post, _context), do: nil
end
