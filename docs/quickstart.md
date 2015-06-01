# Quickstart

## Usage

More detailed information on initialization and authorization is available in the
[Authorization section](usage/authorization/Authorization.md)

### Initialize

```ruby
require 'ringcentral_sdk'

rcsdk = RingCentralSdk::Sdk.new(
  "myAppKey",
  "myAppSecret",
  RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)
platform = rcsdk.platform
```

### Authorization

```ruby
# Initialize using user phone number without extension number

platform.authorize("myUsername", nil, "myPassword")

# Initialize using main phone number and extension number

platform.authorize("myUsername", "myExtension", "myPassword")
```

See the [Authorization section](usage/authorization/Authorization.md) for more examples, including
how to use an `OAuth2::AccessToken` directly.

## Creating Requests

Requests are made using the inclued Faraday client which adds the requisite OAuth bearer token.

Any API request can be made via this method.

```ruby
client = rcsdk.platform.client
```
## Create SMS Message

SMS and other requests can be easily sent directly without helpers.

```ruby
# Send SMS - POST request

response = client.post do |req|
  req.url 'account/~/extension/~/sms'
  req.headers['Content-Type'] = 'application/json'
  req.body = {
    :from =>   { :phoneNumber => '16505551212' },
    :to   => [ { :phoneNumber => '14155551212'} ],
    :text => 'RingCentral SMS demo using Ruby!'
  }
end
```
