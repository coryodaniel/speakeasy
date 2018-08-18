# Speakeasy

Middleware based authentication and authorization for [Absinthe](https://hexdocs.pm/absinthe) GraphQL powered by [Bodyguard](https://hexdocs.pm/bodyguard)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `speakeasy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:speakeasy, "~> 0.1.0"}
  ]
end
```

## Usage

There are two ways to use Speakeasy to authorize GraphQL queries and mutations.

Policies are just regular [Bodyguard](https://github.com/schrockwell/bodyguard) policies with two small changes:

1.  Your `authorize/3` functions will receive the GraphQL `context` instead of a `user`. (Your context, probably includes the user).
2.  Your policies are written for GraphQL queries and mutations rather than bounded contexts.

```elixir
defmodule MyAppWeb.Schema do
  use Absinthe.Schema

  def authorize(:create_post, %{current_user: user} = context, post) do
    IO.inspect(user)
    IO.inspect(context)

    # Return :ok or true to permit
    # Return :error, {:error, reason}, or false to deny
  end
end
```

### Using Absinthe Middleware

Absinthe supports a middleware stack that can be modified at the field or schema level.

Below is an example of adding authentication and authorization to a GraphQL field.

```elixir
defmodule MyAppWeb.Schema do
  use Absinthe.Schema

  def authorize(:create_post, _context, _args) do
    # Return :ok or true to permit
    # Return :error, {:error, reason}, or false to deny
  end

  mutation do
    @desc "Create a post"
    field :create_post, type: :post do
      middleware(Speakeasy.Authentication)
      # Optionally you can pass an atom as the second argument to
      # set the name of the key to use for checking the current user. The default is `:current_user`
      # middleware(Speakeasy.Authentication, :current_user)
      middleware(Speakeasy.Authorization)

      arg(:title, non_null(:string))
      arg(:body, non_null(:string))

      resolve(fn _, args, _ ->
        MyApp.Posts.create_post(args)
      end)
    end
  end
end
```

Alternatively you can use `defdelegate` to separate your schema and policy code:

```elixir
defmodule MyAppWeb.Schema.Policy do
  def authorize(:create_post, _context, _args) do
    # Return :ok or true to permit
    # Return :error, {:error, reason}, or false to deny
  end
end

defmodule MyAppWeb.Schema do
  use Absinthe.Schema
  defdelegate authorize(action, user, params), to: MyAppWeb.Schema.Policy

  mutation do
    @desc "Create a post"
    field :create_post, type: :post do
      middleware(Speakeasy.Authentication)
      middleware(Speakeasy.Authorization)

      arg(:title, non_null(:string))
      arg(:body, non_null(:string))

      resolve(fn _, args, _ ->
        MyApp.Posts.create_post(args)
      end)
    end
  end
end
```

Check out the [documentation](https://hexdocs.pm/absinthe/Absinthe.Middleware.html) for more details on how to use Absinthe middleware.

### `Speakeasy.resolve/2` or `Speakeasy.resolve!/2`

Speakeasy also includes a function and a macro that can be used in line with your field's resolve function if using the middleware doesn't suite your needs:

```elixir
defmodule MyAppWeb.Schema do
  use Absinthe.Schema

  mutation do
    @desc "Create a post"
    field :create_post, type: :post do
      resolve(Speakeasy.resolve(MyApp.Posts, :create_post))

      # or alternatively `resolve!/2` for compile time checking that your resolution function supports the correct arity.
      # resolve(Speakeasy.resolve!(MyApp.Posts, :create_post))
    end
  end
end
```

If authorized `resolve/2` and `resolve!/2` will return an anonymous function to Absinthe's `resolve` function wrapping your resolution function (`MyApp.Posts.create_post` above).

Speakeasy will provide different arguments depending on your resolution functions arity. For example:

- `MyApp.Posts.list_post/0` - speakeasy will simply call this function
- `MyApp.Posts.create_post/1` - speakeasy will call this function passing the GraphQL arguments
- `MyApp.Posts.create_post/2` - speakeasy will call this function passing the GraphQL arguments as the first parameter and the GraphQL context as the second.
