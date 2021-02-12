defmodule Speakeasy.Authz do
  @moduledoc """
  Authorization middleware for Absinthe.

  Please see the [README](readme.html) for a complete example in a Absinthe Schema.
  """

  @behaviour Absinthe.Middleware

  @doc """
  Authorizes the operation using [Bodyguard](https://github.com/schrockwell/bodyguard) policies.

  `Speakeasy.Authn` and `Speakeasy.LoadResource` must occur before calling `Authz`

  Covering policies is beyond the scope of these docs, but a simple example is below:
      defmodule MyApp.Posts do
        defdelegate authorize(action, user, params), to: MyApp.Posts.Policy
      end

      defmodule MyApp.Posts.Policy do
        @behaviour Bodyguard.Policy

        @spec authorize(atom(), %User{} | nil, map()) :: :ok | {:error, String.t()}
        # Allow any user to create a post
        def authorize(:create_post, %User{}, _params), do: true

        # Only allow an author to get a post in draft state
        def authorize(:get_post, %User{id: user_id}, %Post{user_id: user_id, draft: true}), do: true

        # Default blacklist
        def authorize(_, _, _), do: {:error, "Get outta here fool!"}
      end

  ## Examples
    Authorizing takes a tuple of `{resource_module, action}`:

      object :post_mutations do
        @desc "Create post"
        field :create_post, type: :post do
          arg(:name, non_null(:string))
          middleware(Speakeasy.Authn)
          middleware(Speakeasy.LoadResource, fn(attrs) -> a_function_that_loads_the_resource end)
          middleware(Speakeasy.Authz, {MyApp.Posts, :create_post})
        end
      end
  """
  @impl true
  def call(%{state: :unresolved} = res, {m, f}), do: call(res, authorizer: {m, f})

  def call(%{state: :unresolved} = res, opts) when is_list(opts) do
    options = Enum.into(opts, %{})
    call(res, options)
  end

  def call(%{state: :unresolved, context: %{speakeasy: speakeasy}} = res, %{
        authorizer: {policy, action}
      }) do
    resource_or_args = speakeasy.resource || res.arguments

    case Bodyguard.permit(policy, action, speakeasy.user, resource_or_args) do
      :ok -> res
      {:error, _} -> Absinthe.Resolution.put_result(res, {:error, default_error_message()})
    end
  end

  def call(%{state: :unresolved}, %{}),
    do: raise(ArgumentError, message: "`:authorizer` is required")

  def call(res, _), do: res

  @doc false
  def default_error_message() do
    Application.get_env(:speakeasy, :authz_error_message)
  end
end
