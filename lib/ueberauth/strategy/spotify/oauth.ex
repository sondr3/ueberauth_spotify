defmodule Ueberauth.Strategy.Spotify.OAuth do
  @moduledoc """
  Spotify OAuth2 strategy for Überauth.
  """

  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  @defaults [
    strategy: __MODULE__,
    site: "https://api.spotify.com/v1",
    authorize_url: "https://accounts.spotify.com/authorize",
    token_url: "https://accounts.spotify.com/api/token",
    headers: [{"user-agent", "ueberauth-spotify"}]
  ]

  @doc """
  Construct a client for requests to Spotify.

  Optionally include any OAuth2 options here to be merged with the defaults:

      Ueberauth.Strategy.Spotify.OAuth.client(
        redirect_uri: "http://localhost:4000/auth/spotify/callback"
      )

  This will be setup automatically for you in `Ueberauth.Strategy.Spotify`.

  These options are only useful for usage outside the normal callback phase of
  Ueberauth.
  """
  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.Spotify.OAuth, [])

    client_opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    json_library = Ueberauth.json_library()

    client_opts
    |> OAuth2.Client.new()
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  def get(token, url, headers \\ [], opts \\ []) do
    [token: token]
    |> client()
    |> OAuth2.Client.get(url, headers, opts)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth. No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client()
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.get_token!(params)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> put_header(
      "Authorization",
      "Basic " <> auth_header(client.client_id, client.client_secret)
    )
    |> AuthCode.get_token(params, headers)
  end

  @spec auth_header(String.t(), String.t()) :: String.t()
  defp auth_header(client_id, client_secret) do
    Base.encode64("#{client_id}:#{client_secret}")
  end
end
