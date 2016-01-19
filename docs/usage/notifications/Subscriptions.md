# Notifications: Subscription API

## Subscribing to All Extensions

A common use case is to subscribe to the presence events on multiple or all extensions of a RingCentral account. This can be done with 2 API calls for accounts with 1000 or fewer extensions, one API call to get extension info for up to 1000 extensions and a second API call to subscribe to those extensions as event filters. Add 1 API call per each additional 1000 extensions.

### Description

To subscribe to presence events for all extensions, create a set of extension presenence event filters including a presence event filter for every extension, and then create a subscription including all the event filters. A presence event filter includes the accound id and extension id. Here is an example of a single presence event filter using the account id for the authorized session:

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

### Step 1: List All Extensions

To get a list of all extensions, you can call the `/restapi/v1.0/account/~/extension` API endpoint and request extensions up to 1000 per API call. If you have more than 1000 extensions, you can retrieve subsequent pages of extensions using the `navigation.nextPage.uri` property.

The following code will retrieve all extensions at 1000 extensions per API call:

```ruby
# Get all account extensions
def get_all_extensions(rcsdk, account_id='~')
  extension_ids_map = {}
  extensions = []
  res = rcsdk.client.get do |req|
    req.url "/restapi/v1.0/account/#{account_id}/extension"
    req.params['page']    = 1
    req.params['perPage'] = 1000
    req.params['status']  = 'Enabled'
  end
  res.body['records'].each do |record|
    if !extension_ids_map.has_key?(record['id'])
      extensions.push record
      extension_ids_map[record['id']] = 1
    end
  end
  while res.body.has_key?('navigation') && res.body['navigation'].has_key?('nextPage')
    res = rcsdk.client.get do |req|
      req.url res.body['navigation']['nextPage']['uri']
    end
    res.body['records'].each do |record|
      if !extension_ids_map.has_key?(record['id'])
        extensions.push record
        extension_ids_map[record['id']] = 1
      end
    end
  end
  return extensions
end

extensions = get_all_extensions(rcsdk)
```

### Step 2: Build an Array of Event Filters from Extensions

To create an array of extension presence event filters of the following format:

```
/restapi/v1.0/account/#{account_id}/extension/#{ext['id']}/presence?detailedTelephonyState=true
```

Convert the array of extension above to an array of event_filters with the following:

```ruby
# Create an array of event_filters from the array of extensions
def get_event_filters_for_extensions(extensions, account_id='~')
  event_filters = []

  extensions.each do |ext|
    if ext.has_key?('id')
      event_filter = "/restapi/v1.0/account/#{account_id}/extension/#{ext['id']}" +
        "/presence?detailedTelephonyState=true"
      event_filters.push event_filter
    end
  end
  return event_filters
end

event_filters = get_event_filters_for_extensions(extensions)
```

### Step 3: Subscribe to Presence Events for an Array of Extensions

For the array of extension presents event filters, a single subscription API is needed as follows:

```ruby
# Run the event filters in a single subscription API call
def run_subscription(rcsdk, event_filters)
  # Create an observable subscription and add your observer
  sub = rcsdk.create_subscription()
  sub.subscribe(event_filters)

  # Add observer
  sub.add_observer(MyObserver.new())

  # Run until user clicks key to finish
  puts "Click any key to finish"
  stop_script = gets

  # End the subscription
  sub.destroy()
end

run_subscription(rcsdk, event_filters)
```