# Speakeasy

Middleware based authentication and authorization for [Absinthe](https://hexdocs.pm/absinthe) GraphQL powered by [Bodyguard](https://hexdocs.pm/bodyguard)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `speakeasy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:speakeasy, "~> 0.3.0"}
  ]
end
```

## Configuration

Configuration can be done in each Absinthe middleware call, but you can set global defaults as well.

```elixir
config :speakeasy,
  user_key: :current_user,                # the key the current user will be under in the GraphQL context
  authn_error_message: :unauthenticated  # default authentication failure message
```

_Note:_ no `authz_error_message` is provided because it is set from Bodyguard.

## Usage

Show a `posts` schema.

```elixir
resolve(fn(_p, args, ctx) ->
  {:ok, ctx[:speakeasy].resource}
end)

vs Resolve
```

### Middleware

Speakeasy is a collection of Absinthe middlewares:

- [Speakeasy.Authn]()

- [Speakeasy.LoadResource]()

- [Speakeasy.LoadResourceById]()

- [Speakeasy.AuthZ]()

- [Speakeasy.Resolve]()

### Speakeasy.Plug

Speakeasy includes a Plug for loading the current user into the Absinthe context. It isn't required if you already have a method for loading the user into your Absinthe context.

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :graphql do
    plug(Speakeasy.Plug, load_user: &MyApp.Users.whoami/1, user_key: :current_user)
  end
end
```
