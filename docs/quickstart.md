# Quickstart

## Usage

More detailed information on initialization and authorization is available in the
[Authorization section](usage/authorization/Authorization.md)

### Initialize

```ruby
require 'ringcentral_sdk'

client = RingCentralSdk.new(
  "myAppKey",
  "myAppSecret",
  RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)
```

### Authorization

```ruby
# Initialize using user phone number without extension number

client.authorize("myUsername", nil, "myPassword")

# Initialize using main phone number and extension number

client.authorize("myUsername", "myExtension", "myPassword")
```

See the [Authorization section](usage/authorization/Authorization.md) for more examples, including
how to use an `OAuth2::AccessToken` directly.

## Creating Requests

Requests are made using the inclued Faraday client which adds the requisite OAuth bearer token.

Any API request can be made via this method.

```ruby
http = client.http
```
## Create SMS Message

SMS and other requests can be easily sent directly without helpers.

```ruby
# Send SMS - POST request
response = client.messages.sms.create(
  from: '+16505551212',
  to: '+14155551212',
  text: 'Hi there!'
)
```

## Create Subscription

To make subscriptions with RingCentral, use the SDK object to create subscription Observer object and then add observers to it.

```ruby
# Create an observer object
class MyObserver
  def update(message)
    puts "Subscription Message Received"
    puts JSON.dump(message)
  end
end

# Create an observable subscription and add your observer
sub = client.create_subscription()
sub.subscribe(['/restapi/v1.0/account/~/extension/~/presence'])
sub.add_observer(MyObserver.new())

# End the subscription
sub.destroy()
```

More information is available on [subscribing to all extensions](usage/notifications/Subscriptions-All-Extensions.md)
