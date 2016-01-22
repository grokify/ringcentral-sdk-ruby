# Notifications: Subscription API

## Subscribing to All Extensions

A common use case is to subscribe to the presence events on multiple or all extensions of a RingCentral account. This can be done with 2 API calls for accounts with 1000 or fewer extensions, one API call to get extension info for up to 1000 extensions and a second API call to subscribe to those extensions as event filters. Add 1 API call per each additional 1000 extensions.

### Description

To subscribe to presence events for all extensions, create a set of extension presence event filters including a presence event filter for every extension, and then create a subscription API call for the event filter array. A presence event filter includes the account id and extension id. Here is an example of a single presence event filter using the account id for the authorized session:

```
/restapi/v1.0/account/~/extension/111111/presence
```

A set of presence event filters in JSON format looks like the following:

```
[
  "/restapi/v1.0/account/~/extension/111111/presence",
  "/restapi/v1.0/account/~/extension/222222/presence"
]
```

Detailed presence events can be retrived by adding the `detailedTelephonyState=true` query string parameter

```
/restapi/v1.0/account/~/extension/111111/presence?detailedTelephonyState=true
```

A full set of extension ids can be retrieved via the extension endpoint: `/restapi/v1.0/account/~/extension`. This has been tested with a single subscription API call and a set of over 2000 extensions.

The following code steps from the [`scripts/subscription_all_extensions.rb`](https://github.com/grokify/ringcentral-sdk-ruby/blob/master/scripts/subscription_all_extensions.rb) demo script in the Ruby SDK shows how this can be done.

### Step 1: List All Extensions Ids

To get a list of all extensions, you can use `RingCentralSdk::Cache::Extensions` to retrieve all extensions of interest.

```ruby
# Initialize client SDK
rc_api = RingCentralSdk.new ...
rc_api.login ... # Authorize

# Retrieve all Enabled extensions
extensions = RingCentralSdk::Cache::Extensions.new rc_api
extensions.retrieve 'account/~/extension', {'status' => 'Enabled'}, true
extension_ids = extensions.extensions_hash.keys
```

The SDK performs this using the following steps:

1. Retrieve extensions using the `account/~/extension` endpoint
2. If the retrieve all parameter is set to true, follow subsequent `navigation.nextPage.uri` properties until complete

### Step 2: Build an Array of Event Filters from Extensions

To create an array of extension presence event filters of the following format:

```
/restapi/v1.0/account/#{account_id}/extension/#{extension_id}/presence?detailedTelephonyState=true
```

Convert the array of extension above to an array of event_filters with the following:

```ruby
# Create an array of event_filters from the array of extensions
def get_event_filters_for_extensions(extension_ids, account_id='~')
  event_filters = []

  extension_ids.each do |extension_id|
    if extension_id
      event_filter = "/restapi/v1.0/account/#{account_id}/extension/#{extension_id}" +
        "/presence?detailedTelephonyState=true"
      event_filters.push event_filter
    end
  end
  return event_filters
end

event_filters = get_event_filters_for_extensions(extension_ids)
```

### Step 3: Subscribe to Presence Events for an Array of Extensions

For the array of extension presents event filters, a single subscription API is needed as follows:

```ruby
# Run the event filters in a single subscription API call
def run_subscription(rc_api, event_filters)
  # Create an observable subscription and add your observer
  sub = rc_api.create_subscription()
  sub.subscribe(event_filters)

  # Add observer
  sub.add_observer(MyObserver.new())

  # Run until user clicks key to finish
  puts "Click any key to finish"
  stop_script = gets

  # End the subscription
  sub.destroy()
end

run_subscription(rc_api, event_filters)
```