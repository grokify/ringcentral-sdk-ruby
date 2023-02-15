# Quickstart

## Usage

Below is a simple example using OAuth 2.0 password grant to send an SMS. More detailed information on initialization and authorization is available in the Usage Guide's sections for [configuration](configuration.md), [authorization section](usage/authorization/Authorization.md) and [SMS](usage/messages/SMS-Messages.md).

```ruby
require 'ringcentral_sdk'

client = RingCentralSdk::REST::Client.new do |config|
  config.server_url = 'https://platform.ringcentral.com'
  config.app_key = 'my_app_key',
  config.app_secret = 'my_app_secret'

  config.username = 'my_username'
  config.extension = 'my_extension'
  config.password = 'my_password'
end

# Create SMS Message
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
sub = client.create_subscription
sub.subscribe ['/restapi/v1.0/account/~/extension/~/presence']
sub.add_observer MyObserver.new

# End the subscription
sub.destroy
```

More information is available on [subscribing to all extensions](usage/notifications/Subscriptions-All-Extensions.md)
