defmodule Ueberauth.Strategy.Spotify do
  @moduledoc """
  Spotify OAuth2 strategy for Überauth.
  """

  use Ueberauth.Strategy,
    uid_field: :uid,
    default_scope: "user-read-email",
    oauth2_module: Ueberauth.Strategy.Spotify.OAuth

  alias Ueberauth.Strategy.Spotify.OAuth

  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra
  alias Ueberauth.Auth.Info
  alias Ueberauth.Strategy.Helpers

  def handle_request!(conn) do
    scopes = conn.params["scope"] || option(conn, :default_scope)
    opts = [scope: scopes]

    opts =
      if conn.params["state"], do: Keyword.put(opts, :state, conn.params["state"]), else: opts

    callback_url = callback_url(conn)

    opts =
      opts
      |> Keyword.put(:redirect_uri, callback_url)
      |> Helpers.with_state_param(conn)

    redirect!(conn, OAuth.authorize_url!(opts))
  end

  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    options = [redirect_uri: callback_url(conn)]

    try do
      client = OAuth.get_token!([code: code], options)
      token = client.token

      if token.access_token == nil do
        err = token.other_params["error"]
        desc = token.other_params["error_description"]
        set_errors!(conn, [error(err, desc)])
      else
        fetch_user(conn, client)
      end
    rescue
      e -> set_errors!(conn, [error("get_token_error", e)])
    end
  end

  def handle_callback!(%Plug.Conn{params: %{"error" => error}} = conn) do
    set_errors!(conn, [error("error", error)])
  end

  def handle_cleanup!(conn) do
    conn
    |> put_private(:spotify_token, nil)
    |> put_private(:spotify_user, nil)
  end

  defp fetch_user(conn, client) do
    conn = put_private(conn, :spotify_token, client.token)

    case OAuth2.Client.get(client, "/me") do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])

      {:ok, %OAuth2.Response{status_code: status_code, body: user}}
      when status_code in 200..399 ->
        put_private(conn, :spotify_user, user)

      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.spotify_user

    %Info{
      name: user["display_name"],
      nickname: user["id"],
      email: user["email"],
      image: List.first(user["images"])["url"],
      urls: %{external: user["external_urls"]["spotify"], spotify: user["uri"]},
      location: user["country"]
    }
  end

  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.spotify_token,
        user: conn.private.spotify_user
      }
    }
  end

  @doc """
  Includes the credentials from the Spotify response.
  """
  def credentials(conn) do
    token = conn.private.spotify_token
    scopes = token.other_params["scope"] || ""
    scopes = String.split(scopes, ",")

    %Credentials{
      token: token.access_token,
      refresh_token: token.refresh_token,
      expires_at: token.expires_at,
      token_type: token.token_type,
      expires: !!token.expires_at,
      scopes: scopes
    }
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end
end
