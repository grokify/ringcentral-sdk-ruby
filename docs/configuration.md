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
  config.app_key = 'myAppKey'
  config.app_secret = 'myAppSecret'
  config.server_url = RingCentralSdk::RC_SERVER_SANDBOX

  # User info for password grant (optional)
  config.username = 'myUsername'
  config.extension = 'myExtension'
  config.password = 'myPassword'

  config.logger = Logger.new(STDOUT)
  config.retry = true
end
```

## Example using OAuth 2.0 Authorization Code Grant

```ruby
require 'ringcentral_sdk'

client = RingCentralSdk::REST::Client.new do |config|
  # App info (mandatory)
  config.app_key = 'myAppKey'
  config.app_secret = 'myAppSecret'
  config.server_url = RingCentralSdk::RC_SERVER_SANDBOX

  # OAuth 2.0 authorization code grant (optional)
  # Can be set later
  config.redirect_url = 'http://example.com/oauth'

  config.logger = Logger.new(STDOUT)
  config.retry = true
  config.retry_opts = { retry_after: 15, error_codes: [429, 503, 504] }
end
```

## Using Environment Variables

When deploying an app, it can be useful to store some variables outside of the app code. This is especially useful for app and user credentials that should not be checked into source control systems. The RingCentral SDK supports reading some information from the environment, either directly or via a `.env` file. To use this capability set `config.load_env = true`.

Ruby file:

```ruby
require 'ringcentral_sdk'

client = RingCentralSdk::REST::Client.new do |config|
  config.load_env = true
end
```

The following environment variables will be loaded:

| ENV variable | Config setting | Notes |
|--------------|----------------|-------|
| `RC_SERVER_URL` | `config.server_url` |
| `RC_APP_KEY` | `config.app_key` |
| `RC_APP_SECRET` | `config.app_secret` |
| `RC_APP_REDIRECT_URL` | `config.app_redirect_url` |
| `RC_USER_USERNAME` | `config.username` |
| `RC_USER_EXTENSION` | `config.extension` |
| `RC_USER_PASSWORD` | `config.password` |
| `RC_TOKEN` | `config.token` | JSON token response |
| `RC_TOKEN_FILE` | `config.token_file` | File containing JSON token response |
