# Speakeasy

[![Hex.pm](http://img.shields.io/hexpm/v/speakeasy.svg?style=flat)](https://hex.pm/packages/speakeasy) [![Hex.pm](https://img.shields.io/hexpm/dw/speakeasy.svg?style=flat)](https://hex.pm/packages/speakeasy) ![Hex.pm](https://img.shields.io/hexpm/l/speakeasy.svg?style=flat)

[Speakeasy](https://hexdocs.pm/speakeasy/readme.html) is middleware based authentication and authorization for [Absinthe](https://hexdocs.pm/absinthe) GraphQL powered by [Bodyguard](https://hexdocs.pm/bodyguard).

[Docs](https://hexdocs.pm/speakeasy/readme.html)

## Installation

[Speakeasy](https://hex.pm/packages/speakeasy) can be installed
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

**tl;dr:** A full example authentication, authorizing, loading, and resolving an Absinthe schema:

_This example assumes:_

- You are authorizing a standard phoenix context
- You already have a [bodyguard policy](https://github.com/schrockwell/bodyguard#policies)
- Your `:current_user` is already in the Absinthe context _or_ you are using [`Speakeasy.Plug`](#speakeasy-plug)

```elixir
defmodule MyApp.Schema.PostTypes do
  use Absinthe.Schema.Notation
  alias Spectra.Posts

  object :post do
    field(:id, non_null(:id))
    field(:name, non_null(:string))
  end

  object :post_mutations do
    @desc "Create post"
    field :create_post, type: :post do
      arg(:name, non_null(:string))
      middleware(Speakeasy.Authn)
      middleware(Speakeasy.Authz, {Posts, :create_post})
      middleware(Speakeasy.Resolve, &Posts.create_post/2)
      middleware(MyApp.Middleware.ChangesetErrors) # :D
    end

    @desc "Update post"
    field :update_post, type: :post do
      arg(:name, non_null(:string))
      middleware(Speakeasy.Authn)
      middleware(Speakeasy.Authz, {Posts, :update_post})
      middleware(Speakeasy.Resolve, &Posts.update_post/3)
      middleware(MyApp.Middleware.ChangesetErrors) # :D
    end
  end

  object :post_queries do
    @desc "Get posts"
    field :posts, list_of(:post) do
      middleware(Speakeasy.Authn)
      middleware(Speakeasy.Resolve, fn(attrs, user) -> MyApp.Posts.search(attrs, user) end)
    end

    @desc "Get post"
    field :post, type: :post do
      arg(:id, non_null(:string))
      middleware(Speakeasy.Authn)
      middleware(Speakeasy.LoadResourceByID, &Posts.get_post/1)
      middleware(Speakeasy.Authz, {Posts, :get_post})
      middleware(Speakeasy.Resolve)
    end
  end
end
```

And of course you can use Absinthe's resolve function as well:

```elixir
@desc "Get post"
field :post, type: :post do
  arg(:id, non_null(:string))
  middleware(Speakeasy.Authn)
  middleware(Speakeasy.LoadResourceByID, &Posts.get_post/1)
  middleware(Speakeasy.Authz, {Posts, :get_post})
  resolve(fn(_parent, _args, ctx) ->
    {:ok, ctx[:speakeasy].resource}
  end)
end
```

### Middleware

Speakeasy is a collection of Absinthe middleware:

- [Speakeasy.Authn](https://hexdocs.pm/speakeasy/Speakeasy.Authn.html#content) - Resolution middleware for Absinthe.

- [Speakeasy.LoadResource](https://hexdocs.pm/speakeasy/Speakeasy.LoadResource.html#content) - Loads a resource into the speakeasy context.

- [Speakeasy.LoadResourceById](https://hexdocs.pm/speakeasy/Speakeasy.LoadResourceByID.html#content) - A convenience middleware to `LoadResource` using the `:id` in the Absinthe arguments.

- [Speakeasy.AuthZ](https://hexdocs.pm/speakeasy/Speakeasy.Authz.html#content) - Authorization middleware for Absinthe.

- [Speakeasy.Resolve](https://hexdocs.pm/speakeasy/Speakeasy.Resolve.html#content) - Resolution middleware for Absinthe.

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
