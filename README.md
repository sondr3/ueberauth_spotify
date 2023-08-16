# UeberauthSpotify

> Spotify OAuth2 strategy for Überauth.

## Installation

1. Setup your application at [Spotify API](https://developer.spotify.com/documentation/web-api/tutorials/getting-started).

1. Add `:ueberauth_spotify` to your list of dependencies in `mix.exs`:

   ```elixir
   def deps do
     [{:ueberauth_spotify, git: "https://github.com/sondr3/ueberauth-spotify", tag: "0.1"}]
   end
   ```

1. Add Spotify to your Überauth configuration:

   ```elixir
   config :ueberauth, Ueberauth,
     providers: [
       spotify: {Ueberauth.Strategy.Spotify, []}
     ]
   ```

1. Update your provider configuration:

   ```elixir
    config :ueberauth, Ueberauth.Strategy.Spotify.OAuth,
      client_id: System.get_env("SPOTIFY_CLIENT_ID"),
      client_secret: System.get_env("SPOTIFY_CLIENT_SECRET")
   ```

1. Include the Überauth plug in your controller:

   ```elixir
   defmodule MyApp.AuthController do
     use MyApp.Web, :controller
     plug Ueberauth
     ...
   end
   ```

1. Create the request and callback routes if you haven't already:

   ```elixir
   scope "/auth", MyApp do
     pipe_through :browser

     get "/:provider", AuthController, :request
     get "/:provider/callback", AuthController, :callback
   end
   ```

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initiate the request through:

    /auth/spotify

Or with options:

    /auth/spotify?scope=playlist-modify-private&show_dialog=true

By default the requested scope is "user-read-email". Scope can be configured either explicitly as a `scope` query value on the request path or in your configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    spotify: {Ueberauth.Strategy.Spotify, [default_scope: "user-read-private user-read-email"]}
  ]
```

## License

Please see [LICENSE](https://github.com/sondr3/ueberauth_spotify/blob/main/LICENSE) for licensing details.
