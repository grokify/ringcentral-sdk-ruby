# Subscriptions

## Synopsis

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
sub.add_observer(MyObserver.new())

# Subscribe to an arbitrary number of event filters
sub.subscribe(['/restapi/v1.0/account/~/extension/~/presence'])

# End the subscription
sub.destroy()
```

You can subscribe to multiple extensions by adding multiple event filters to a single subscription API call.