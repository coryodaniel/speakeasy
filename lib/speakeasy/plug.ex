defmodule Speakeasy.Plug do
  @moduledoc """
  Absinthe context plug
  """
  @behaviour Plug
  import Plug.Conn

  @doc """
  This plug is based off of the [Absinthe example plug](https://hexdocs.pm/absinthe/context-and-authentication.html).

  It takes two arguments:

  `load_user` which accepts a 1 arity function that should return your user. It will receive the value of the bearer HTTP `authorization` header.

  `user_key` the name of the map key to put the user under in the GraphQL context.

  ## Examples

      plug(Speakeasy.Plug, load_user: &some_function/1, user_key: :current_user)

  """
  def init(opts) do
    defaults = [
      load_user: fn token -> token end,
      user_key: Speakeasy.default_user_key()
    ]

    Keyword.merge(defaults, opts)
  end

  def call(conn, opts) do
    token = get_token(conn)
    user = opts[:load_user].(token)
    context = Map.put(%{}, opts[:user_key], user)
    Absinthe.Plug.put_options(conn, context: context)
  end

  @doc """
  Get the `authorization` HTTP header _bearer_ token
  """
  def get_token(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
      token
    else
      _ -> nil
    end
  end
end
