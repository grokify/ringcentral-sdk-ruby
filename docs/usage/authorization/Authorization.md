# Authorization

This RingCentral SDK for Ruby has several methods for authentication and accessing
resources. This allows you to select the best method for your use case.

1. Reference Approach - single user via password strategy used by RC Official SDKs
1. Simple Approach - single user via password strategy - less verbose
1. Generic Approach - accepts any `OAuth2::AccessToken`

## Reference Approach

This is the reference OAuth2 password strategy authorization used by the official
RingCentral SDKs:

```ruby
sdk = RingCentralSdk::Sdk.new(
  'my_app_key', 'my_app_secret', RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)

platform = sdk.platform

platform.authorize( 'my_username', 'my_extension', 'my_password' )
```

## Simple Approach

A simple approach is provided as optional parameters in the the SDK's constructor
method which will execute the OAuth2 password stategy when present. This is useful
for single queries where you do not need to reuse the SDK object.

```ruby
sdk = RingCentralSdk::Sdk.new(
  'my_app_key', 'my_app_secret',
  RingCentralSdk::Sdk::RC_SERVER_SANDBOX, # or RingCentralSdk::Sdk::RC_SERVER_PRODUCTION
  'my_username', 'my_extension', 'my_password'
)
```

With chaining and request helper:

```ruby
response = RingCentralSdk::Sdk.new(
  'my_app_key', 'my_app_secret', RingCentralSdk::Sdk::RC_SERVER_SANDBOX,
  'my_username', 'my_extension', 'my_password'
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

## Generic Approach

Using the generic authorization approach, any `OAuth2::AccessToken` can be
provided, allowing you more flexibility.

```ruby
sdk = RingCentralSdk::Sdk.new(
  'myAppKey', 'myAppSecret', RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)

oauth2 = OAuth2::Client.new(@app_key, @app_secret,
  :site      => sdk.platform.server_url,
  :token_url => RingCentralSdk::Platform::Platform::TOKEN_ENDPOINT)

token = oauth2.password.get_token('my_username', 'my_password', {
  :extension => 'my_extension',
  :headers   => { 'Authorization' => 'Basic ' + sdk.platform.get_api_key() } })

sdk.platform.authorized(token)
```

## Token Reuse

To reuse an access token between sessions, you can save the hash of the token, 
store it, and then reuse it in another SDK instance.

```ruby
sdk = RingCentralSdk::Sdk.new(
  'my_app_key', 'my_app_secret', RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)
sdk.platform.authorize( 'my_username', 'my_extension', 'my_password' )

# Save token
token_hash = sdk.platform.token.to_hash

# New SDK Instance
sdk2 = RingCentralSdk::Sdk.new(
  'my_app_key', 'my_app_secret', RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)

# Method 1: Load token as hash
sdk2.platform.set_token(token_hash)

# Method 2: Load token as OAuth2::AccessToken object
oauth2 = OAuth2::Client.new(@app_key, @app_secret,
  :site      => sdk2.platform.server_url,
  :token_url => sdk2.platform.class::TOKEN_ENDPOINT)

token = OAuth2::AccessToken::from_hash(oauth2, token_hash)

sdk2.platform.set_token(token)
```

## Implementation

The SDK currently provides a configured `faraday` client to make client requests.
Token management is managed by the `oauth2` gem using a `OAuth2::AccessToken`.