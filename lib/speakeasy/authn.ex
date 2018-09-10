defmodule Speakeasy.Authn do
  @moduledoc """
  Authentication middleware for Absinthe.

  See the [README](readme.html) for a complete example in a Absinthe Schema.
  """

  @behaviour Absinthe.Middleware

  @doc """
  Considers the context authenticated if a non-null value is exists under `:user_key` in the `Absinthe.Resolution` `:context`


  ## Examples
    `:user_key` and `:authn_error_message` can be set globally and be overwritten per middleware call:

      config :speakeasy,
        user_key: :current_user,               # the key the current user will be under in the GraphQL context
        authn_error_message: :unauthenticated  # default authentication

    Authenticating using default options:

      object :post_mutations do
        @desc "Create post"
        field :create_post, type: :post do
          arg(:name, non_null(:string))
          middleware(Speakeasy.Authn)
        end
      end

    Authenticating using a custom `:user_key`

      object :post_mutations do
        @desc "Create post"
        field :create_post, type: :post do
          arg(:name, non_null(:string))
          middleware(Speakeasy.Authn, user_key: :user)
        end
      end

    Authenticating using a string error `:message`

      object :post_mutations do
        @desc "Create post"
        field :create_post, type: :post do
          arg(:name, non_null(:string))
          middleware(Speakeasy.Authn, message: "No way")
        end
      end

    Authenticating using a callback error `:message`. This will receive the `Absinthe.Resolution` :context

      object :post_mutations do
        @desc "Create post"
        field :create_post, type: :post do
          arg(:name, non_null(:string))
          middleware(Speakeasy.Authn, message: fn(_ctx) -> "Error message" end)
        end
      end
  """
  @impl true
  def call(res, opts \\ [])

  def call(%{state: :unresolved} = res, opts) do
    defaults = [user_key: Speakeasy.default_user_key(), error_message: default_error_message()]
    options = Keyword.merge(defaults, opts)

    user_key = options[:user_key]
    current_user = res.context[user_key]

    case current_user do
      nil ->
        Absinthe.Resolution.put_result(res, {:error, gen_msg(options[:error_message], res)})

      _ ->
        Speakeasy.Context.add_user(res, current_user)
    end
  end

  def call(res, _), do: res

  defp gen_msg(msg, res) when is_function(msg), do: msg.(res)
  defp gen_msg(msg, _), do: msg

  @doc false
  def default_error_message() do
    Application.get_env(:speakeasy, :authn_error_message)
  end
end
