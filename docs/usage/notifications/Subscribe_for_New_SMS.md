# Subscribe for New SMS Messages

A common use case is to subscribe to all incoming SMS messages. This can be used to either sync messages or to take action in incoming messages. RingCentral has a couple of ways to retrieve incoming messages. This tutorial describes retrieving messages one at a time where there is no replicated dataset. If you wish to replicate to your own datastore, please contact RingCentral devsupport.

To retrieve incoming SMS messages, there are two steps

1. Subscribe for events on the message store to receive information on new SMS messages
2. Retrieve the messages from the message store by querying the store for the time range

Before continuing, familiarize yourself with [subscriptions](Subscriptions.md)

### Step 1: Subscribe for New SMS events:

For this step, create a subscription to the `/restapi/v1.0/account/~/extension/~/message-store` event filter with the account id and extension id of interest where `~` represents your currently authorized values. When receiving an event, you will receive an array of `changes` of which, some can have the `type` attribute set to `SMS` along with a `newCount` attribute. When `newCount` is > 0, there is a new SMS.

To subscribe for new message store events, use the following:

```ruby
sub = client.create_subscription
sub.subscribe ['/restapi/v1.0/account/~/extension/~/message-store']
```

Information on subscription is here:

* [Dev Guide: Notifications](https://developer.ringcentral.com/api-docs/latest/index.html#!#Notifications.html)
* [API Reference: Notifications](https://developer.ringcentral.com/api-docs/latest/index.html#!#RefNotifications.html)

### Step 2: SMS Retrieval

To retrieve the new SMS message given an subscription, use the event's `body.lastUpdated` time property to retrieve inbound SMS messages matching that time. You can do this with the following steps:

1. Retrieve the event's `body.lastUpdated` property
2. Create a message store API call setting the `dateFrom` and `dateTo` parameters around the event's `body.lastUpdated` property. You can set the range to be 1 second on either side.
3. Upon receiving an array of messages in the response, filter the messages on the message `lastModifiedTime` which will be the same as the event's `body.lastUpdated` time.

To accomplish the above, you can use the Ruby SDK as follows in your observer object:

```ruby
retriever = RingCentralSdk::REST::MessagesRetriever.new client
messages = @retriever.retrieve_for_event event, direction: 'Inbound'
messages.each do |message|
  # do something
end
```

An example observer object shows how to combine these:

```ruby
# Create an observer object
class MyObserver
  def initialize(client)
    @client = client
    @retriever = RingCentralSdk::REST::MessagesRetriever.new client
  end

  def update(message)
    event = RingCentralSdk::REST::Event.new message
    messages = @retriever.retrieve_for_event event, direction: 'Inbound'
    messages.each do |message|
      # do something
    end
  end
end
```

For additional reading, see:

* [Dev Guide: Messaging](https://developer.ringcentral.com/api-docs/latest/index.html#!#MessagingGuide.html)
* [API Reference: Message List](https://developer.ringcentral.com/api-docs/latest/index.html#!#MessageList.html)

### Example Implementation

The above is implemented in an example script using the Ruby SDK. The script retrieves each message and sends it to a Glip chat team using the `Glip::Poster` module. Other chat modules with the same interfae can also be used.

* Script: [sms_to_chat.rb](https://github.com/grokify/ringcentral-sdk-ruby/blob/master/scripts/sms_to_chat.rb)
* SDK : [messages_retriever.rb](https://github.com/grokify/ringcentral-sdk-ruby/blob/master/lib/ringcentral_sdk/rest/messages_retriever.rb)
