# Authorization

This RingCentral SDK for Ruby has several methods for authentication and accessing
resources. This allows you to select the best method for your use case. This page covers the following sections:

1. Authorization Code Grant - 3-legged OAuth for end users supporting SSO
1. Password Grant - 2-legged OAuth for servers no supporting SSO
1. Token Reuse - saving and reusing a token between SDK instances

## Authorization Code Grant

The authorization code grant OAuth 2.0 strategy allows users to securely grant access to their RingCentral resources to your application. This approach is recommend for end-user applications as it supports RingCentral customers that have deployed Single Sign-On (SSO) with third-party Identity Providers (IdPs).

In this case, your application will direct the user to a RingCentral URL where they will authenticate after which your app will receive an authorization code that can be exchanged for an access token.

In addition to the synopsis below, an example Sinatra app is available in the repo's `scripts` directory at [scripts/oauth2-sinatra](https://github.com/grokify/ringcentral-sdk-ruby/tree/master/scripts/oauth2-sinatra).

```ruby
# Initialize SDK with OAuth redirect URI
rcsdk = RingCentralSdk.new(
  'myAppKey',
  'myAppSecret',
  RingCentralSdk::RC_SERVER_SANDBOX,
  {:redirect_uri => 'http://example.com/oauth'}
)
# Retrieve OAuth authorize url using default redirect URL
auth_url = rcsdk.authorize_url()
# Retrieve OAuth authorize url using override redirect URL
auth_url = rcsdk.authorize_url({
  :redirect_uri => 'my_registered_oauth_url', # optional override of default URL
  :display      => '', # optional: page|popup|touch|mobile, default 'page'
  :prompt       => '', # optional: sso|login|consent, default is 'login sso consent'
  :state        => '', # optional
  :brand_id     => ''  # optional: string|number
})
# Open browser window to authUrl and retrieve authorize_code from redirect uri.
```

On your redirect page, you can exchange your authorization code for an access token using the following:

```ruby
code  = params['code'] # retrieve GET 'code' parameter in Sinatra
token = rcsdk.authorize_code(code)
```

## Password Grant

The OAuth 2.0 resource owner password credentials (RPOC) grant allows apps that have the user's password credentials to entire them directly on the user's behalf. This is useful for server applications and does not support IdPs for SSO.

### Reference Approach

This is the reference OAuth2 password strategy authorization used by the official
RingCentral SDKs:

```ruby
rcsdk = RingCentralSdk.new(
  'my_app_key', 'my_app_secret', RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)

rcsdk.authorize( 'my_username', 'my_extension', 'my_password' )
```

### Simple Approach

A simple approach is provided as optional parameters in the the SDK's constructor
method which will execute the OAuth2 password stategy when present. This is useful
for single queries where you do not need to reuse the SDK object.

```ruby
rcsdk = RingCentralSdk.new(
  'my_app_key', 'my_app_secret',
  RingCentralSdk::RC_SERVER_SANDBOX, # or RingCentralSdk::RC_SERVER_PRODUCTION
  {:username => 'my_username', :extension => 'my_extension', :password => 'my_password'}
)
```

With chaining and request helper:

```ruby
response = RingCentralSdk.new(
  'my_app_key', 'my_app_secret', RingCentralSdk::RC_SERVER_SANDBOX,
  {:username => 'my_username', :extension => 'my_extension', :password => 'my_password'}
).request(
  RingCentralSdk::Helpers::CreateFaxRequest.new(
    nil, # for authz user or { :account_id => '~', :extension_id => '~' }
    {
      :to            => '+16505551212', # inflates to [{ :phoneNumber => '+16505551212' }],
      :coverPageText => 'RingCentral fax text example using Ruby!'
    },
    :text     => 'RingCentral fax text example using Ruby!'
  )
)
```

### Generic Approach

Using the generic authorization approach, any `OAuth2::AccessToken` can be
provided, allowing you more flexibility.

```ruby
rcsdk = RingCentralSdk.new(
  'myAppKey', 'myAppSecret', RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)

oauth2 = OAuth2::Client.new(@app_key, @app_secret,
  :site      => rcsdk.server_url,
  :token_url => RingCentralSdk::Platform::Platform::TOKEN_ENDPOINT)

token = oauth2.password.get_token('my_username', 'my_password', {
  :extension => 'my_extension',
  :headers   => { 'Authorization' => 'Basic ' + rcsdk.get_api_key() } })

rcsdk.authorized(token)
```

## Token Reuse

To reuse an access token between sessions, you can save the hash of the token, 
store it, and then reuse it in another SDK instance.

```ruby
rcsdk = RingCentralSdk.new(
  'my_app_key', 'my_app_secret', RingCentralSdk::RC_SERVER_SANDBOX
)
rcsdk.authorize( 'my_username', 'my_extension', 'my_password' )

# Save token
token_hash = rcsdk.token.to_hash

# New SDK Instance
rcsdk2 = RingCentralSdk.new(
  'my_app_key', 'my_app_secret', RingCentralSdk::RC_SERVER_SANDBOX
)

# Method 1: Load token as hash
rcsdk2.set_token(token_hash)

# Method 2: Load token as OAuth2::AccessToken object
oauth2 = OAuth2::Client.new(@app_key, @app_secret,
  :site      => rcsdk2.server_url,
  :token_url => rcsdk2.class::TOKEN_ENDPOINT)

token = OAuth2::AccessToken::from_hash(oauth2, token_hash)

rcsdk2.set_token(token)
```

## Implementation

The SDK currently provides a configured `faraday` client to make client requests.
Token management is managed by the `oauth2` gem using a `OAuth2::AccessToken`.