# Configuring the Ruby SDK

The Ruby SDK configuration block includes several different configuration options for:

1. OAuth 2.0 password grant
2. OAuth 2.0 authorization code grant
3. Configuration using `.env` file

In addition to OAuth 2.0, the SDK provides options for:

1. Logging
1. HTTP Retries
1. Loading via `.env` file

## Eample using OAuth 2.0 Password Grant

```ruby
require 'ringcentral_sdk'

client = RingCentralSdk::REST::Client.new do |config|
  # App info (mandatory)
  config.client_id = 'my_app_client_id'
  config.client_secret = 'my_app_client_secret'
  config.server_url = RingCentralSdk::RC_SERVER_SANDBOX

  # User info for password grant (optional)
  config.username = 'my_username'
  config.extension = 'my_extension'
  config.password = 'my_password'

  config.logger = Logger.new STDOUT
  config.retry = true
end
```

## Example using OAuth 2.0 Authorization Code Grant

```ruby
require 'ringcentral_sdk'

client = RingCentralSdk::REST::Client.new do |config|
  # App info (mandatory)
  config.client_id = 'my_app_client_id'
  config.client_secret = 'my_app_client_secret'
  config.server_url = RingCentralSdk::RC_SERVER_SANDBOX

  # OAuth 2.0 authorization code grant (optional)
  # Can be set later
  config.redirect_url = 'http://example.com/oauth'

  config.logger = Logger.new STDOUT
  config.retry = true
  config.retry_opts = { retry_after: 15, error_codes: [429, 503, 504] }
end
```

## Logging

The RingCentral SDK either takes a Logger object or will create a default `Logger` object. The same object is passed to dependencies including the faraday HTTP client and the faraday request retry middleware gem. This is set using the logger config variable:

```ruby
client = RingCentral::REST::Client.new do |config|
  config.logger = Logger.new STDOUT
  ...
end
```

## HTTP Request Retries 

RingCentral SDK uses `FaradayMiddleware::Request::Retry` to handle HTTP request retries. By default it will retry on 429, 503 and 504 responses. A `Retry-After` header in seconds will be respected, falling back to a default retry after. The following can be set:

* `:error_codes` to retry, default `[429, 503, 504]`
* `:retry_after` seconds, default `10`

Note, there may be issues replay certain types of requests, notably `Faraday::UploadIO` requests. To reply these requests you can use `FaradayMiddleware::Request::RetryUtil` separately as seen in [RingCentral::Avatars::Creator](https://github.com/grokify/ringcentral-avatars-ruby/blob/master/lib/ringcentral-avatars/creator.rb).

## Using Environment Variables

When deploying an app, it can be useful to store some variables outside of the app code. This is especially useful for app and user credentials that should not be checked into source control systems. The RingCentral SDK supports reading some information from the environment, either directly or via a `.env` file. To use this capability set `config.load_env = true`.

The following environment variables will be loaded:

| ENV variable | Config setting | Notes |
|--------------|----------------|-------|
| `RINGCENTRAL_SERVER_URL` | `config.server_url` | Must be set to value of URL, not constant |
| `RINGCENTRAL_CLIENT_ID` | `config.client_id` |
| `RINGCENTRAL_CLIENT_SECRET` | `config.client_secret` |
| `RINGCENTRAL_REDIRECT_URL` | `config.app_redirect_url` |
| `RINGCENTRAL_USERNAME` | `config.username` |
| `RINGCENTRAL_EXTENSION` | `config.extension` |
| `RINGCENTRAL_PASSWORD` | `config.password` |
| `RINGCENTRAL_TOKEN` | `config.token` | JSON token response |
| `RINGCENTRAL_TOKEN_FILE` | `config.token_file` | File containing JSON token response |
| `RINGCENTRAL_RETRY` | `config.retry` | Set to `true` or `false` |
| `RINGCENTRAL_RETRY_OPTIONS` | `config.retry_options | JSON string for `FaradayMiddleware::Request::Retry` options |

Ruby file:

```ruby
require 'ringcentral_sdk'

client = RingCentralSdk::REST::Client.new do |config|
  config.load_env = true
end
```

Example Environment Variables / .env file

```
RINGCENTRAL_SERVER_URL=https://platform.ringcentral.com
RINGCENTRAL_CLIENT_ID=my_app_client_id
RINGCENTRAL_CLIENT_SECRET=my_app_client_secret
RINGCENTRAL_USERNAME=my_username
RINGCENTRAL_EXTENSION=my_extension
RINGCENTRAL_PASSWORD=my_password
```
