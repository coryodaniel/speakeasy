defmodule SpeakeasyTest.Schema do
  def authorize(:create_post, _context, _args), do: :ok
  def authorize(:update_post, _, _), do: true
  def authorize(:delete_post, _, _), do: false
  def authorize(:list_post, _, _), do: {:error, "TOO BAD"}
end
