# Authorization

This RingCentral SDK for Ruby has several methods for authentication and accessing
resources. This allows you to select the best method for your use case. This page covers the following sections:

1. Password Grant - 2-legged OAuth for servers without SSO support
1. Authorization Code Grant - 3-legged OAuth for end users with SSO support
1. Token Reuse - saving and reusing a token between SDK instances
1. Using OAuth2::AccessToken
1. Implementation Notes

## Password Grant

The OAuth 2.0 resource owner password credentials (RPOC) grant allows apps that have the user's password credentials to entire them directly on the user's behalf. This is useful for server applications and does not support IdPs for SSO.

### Reference Approach

This is the reference OAuth2 password strategy authorization used by the official
RingCentral SDKs:

```ruby
client = RingCentralSdk::REST::Client do |config|
  config.server_url = RingCentralSdk::Sdk::RC_SERVER_SANDBOX
  config.app_key = 'my_app_key'
  config.app_secret = 'my_app_secret'

  config.username = 'my_username'
  config.extension = 'my_extension'
  config.password = 'my_password'
end
```

### authorize method

After instantiating the SDK, the `authorize` method can be used to request an authorization by the supplied user.

```ruby
client.authorize 'my_username', 'my_extension', 'my_password'

# Optional OAuth parameters can be passed in
client.authorize 'my_username', 'my_extension', 'my_password', access_token_ttl: 600
```

## Authorization Code Grant

The authorization code grant OAuth 2.0 strategy allows users to securely grant access to their RingCentral resources to your application. This approach is recommend for end-user applications as it supports RingCentral customers that have deployed Single Sign-On (SSO) with third-party Identity Providers (IdPs).

In this case, your application will direct the user to a RingCentral URL where they will authenticate after which your app will receive an authorization code that can be exchanged for an access token.

In addition to the synopsis below, an example Sinatra app is available in the repo's `scripts` directory at [scripts/oauth2-sinatra](https://github.com/grokify/ringcentral-sdk-ruby/tree/master/scripts/oauth2-sinatra).

```ruby
# Initialize SDK with OAuth redirect URI
client = RingCentralSdk::REST::Client.new do |config|
  config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
  config.app_key = 'myAppKey'
  config.app_secret = 'myAppSecret'
  config.app_redirect_url: 'http://example.com/oauth'
end

# Retrieve OAuth authorize url using default redirect URL
auth_url = client.authorize_url

# Retrieve OAuth authorize url using override redirect URL
auth_url = client.authorize_url(
  redirect_uri: 'my_registered_oauth_url', # optional override of default URL
  display:      '', # optional: page|popup|touch|mobile, default 'page'
  prompt:       '', # optional: sso|login|consent, default is 'login sso consent'
  state:        '', # optional
  brand_id:     ''  # optional: string|number
)
# Open browser window to authUrl and retrieve authorize_code from redirect uri.
```

On your redirect page, you can exchange your authorization code for an access token using the following:

```ruby
code  = params['code'] # retrieve GET 'code' parameter in Sinatra
token = client.authorize_code code

# Optional OAuth parameters can be passed in
token = client.authorize_code code, access_token_ttl: 600
```

## Token Refresh

Important! You have to manually maintain synchronization of SDK's between requests if you share authentication. When two simultaneous requests will perform refresh, only one will succeed. One of the solutions would be to have semaphor and pause other pending requests while one of them is performing refresh.

See [the authorization docs](http://ringcentral-sdk-ruby.readthedocs.org/en/latest/usage/authorization/Authorization/) for more info including token reuse.

## Token Reuse

To reuse an access token between sessions, you can save the hash of the token, 
store it, and then reuse it in another SDK instance.

```ruby
client = RingCentralSdk.new(
  'my_app_key', 'my_app_secret', RingCentralSdk::RC_SERVER_SANDBOX
)
client.authorize( 'my_username', 'my_extension', 'my_password' )

# Save token
token_hash = client.token.to_hash

# New SDK Instance
client2 = RingCentralSdk.new(
  'my_app_key', 'my_app_secret', RingCentralSdk::RC_SERVER_SANDBOX
)

# Method 1: Load token as hash
client2.set_token token_hash

# Method 2: Load token as OAuth2::AccessToken object
oauth2 = OAuth2::Client.new(@app_key, @app_secret,
  site:      client2.server_url,
  token_url: client2.class::TOKEN_ENDPOINT)

token = OAuth2::AccessToken::from_hash(oauth2, token_hash)

client2.set_token(token)
```

## Using OAuth2::AccessToken

Using the generic authorization approach, any `OAuth2::AccessToken` can be
provided, allowing you more flexibility.

```ruby
client = RingCentralSdk::REST::Client do |config|
  config.server_url = RingCentralSdk::RC_SERVER_SANDBOX
  config.app_key = 'my_app_key'
  config.app_secret = 'my_app_secret'
)

oauth2 = OAuth2::Client.new(
  'my_app_key',
  'my_app_secret',
  site:      RingCentralSdk::Sdk::RC_SERVER_SANDBOX,
  token_url: RingCentralSdk::Platform::Platform::TOKEN_ENDPOINT
)

token = oauth2.password.get_token(
  'my_username',
  'my_password', {
  extension: 'my_extension',
  headers: { 'Authorization' => 'Basic ' + client.api_key } })

client.set_token token
```

## Implementation Notes

The SDK currently provides a configured `faraday` client to make client requests.
Token management is managed by the `oauth2` gem using a `OAuth2::AccessToken`.
