# Click-To-Call

RingCentral supports two methods for Click-To-Call:

* RingOut API call
* URI Scheme to RingCentral softphone application

Both are covered here.

## RingOut API call

To initiate a RingOut API call, call the ringout endpoint. While the `from` number is optional, if it is used, it must match one of the configured forwarding numbers with the `CallForwarding` feature.

```ruby
# Instantiate client SDK
client = RingCentralSdk.new ...
client.login ...

# RingOut Example
response = client.http.post do |req|
  req.url 'account/~/extension/~/ringout'
  req.headers['Content-Type'] = 'application/json'
  req.body = {
    to: { phoneNumber: '14155551212'}, # to is required
    from: { phoneNumber: '16505551212' }, # from optional
    callerId: { phoneNumber: '14085551212'}, # callerId is optional
    playPrompt: true # playPrompt is optional
  }
end
```

### Retrieving a List of Valid RingOut From Numbers

When building an application that creates RingOut calls it is useful to retrieve a list of phone numbers to pre-select the `from` phone number. This can be done using the `extension/forwarding-number` endpoint and then selecting the phone numbers with the `CallForwarding` feature. A common UX for this is to present a drop down element to allow the user to select a phone number.

To retrieve a list of phone numbers, make a `GET` request to the `extension/forwarding-number` endpoint as follows:

```ruby
# Phone Number Example
response = client.http.get do |req|
  req.url 'account/~/extension/~/phone-number'
end
```

This will return a list of phone numbers assigned the extension as shown below. Filter for the `CallForwarding` `feature` and then use the E.164 `phoneNumber` property value.

```ruby
{
  "uri" => "https://platform.ringcentral.com/restapi/v1.0/account/11111111/extension/22222222/forwarding-number?page=1&perPage=100"
  "records"=> [
    {
      "id" => "33333333",
      "phoneNumber" =>"+16505551212",
      "label"=>"My Phone",
      "features"=>["CallForwarding", "CallFlip"],
      "flipNumber"=>"1"
    }
  ]
}
```

### Retrieving a List of Valid RingOut Caller ID Numbers

To retrieve a list of numbers for Caller ID, use the `extension/phone-number` endpoint and then selecting the phone numbers with the `CallerId` feature. A common UX for this is to present a drop down element to allow the user to select a phone number to send from.

To retrieve a list of phone numbers, make a `GET` request to the `extension/phone-number` endpoint as follows:

```ruby
# Phone Number Example
response = client.http.get do |req|
  req.url 'account/~/extension/~/phone-number'
end
```

This will return a list of phone numbers assigned the extension as shown below. Filter for the `CallerId` `feature` and then use the E.164 `phoneNumber` property value.

```ruby
{
  "uri" => "https://platform.ringcentral.com/restapi/v1.0/account/11111111/extension/22222222/phone-number?page=1&perPage=100"
  "records"=> [
    {
      "id" => 33333333,
      "phoneNumber" => "+16505551212",
      "paymentType" => "Local",
      "type" => "VoiceFax",
      "usageType" => "DirectNumber",
      "features" => ["SmsSender", "CallerId"],
      "status" => "Normal",
      "country" => {
        "uri" => "https://platform.devtest.ringcentral.com/restapi/v1.0/dictionary/country/1",
        "id" => "1",
        "name" => "United States"
      }
    }
  ]
}
```

## URI Scheme

To initiate a Click-To-Call via URI scheme, it is necessary to create a URI that the user will click on. You can use either the standard `tel` URI scheme or the RingCentral `rcmobile` URI scheme. The RingCentral scheme supports multiple functions including SMS.

```html
<!-- rcmobile is only used by RingCentral -->
<a href="rcmobile://call?number=16501112222">1-650-111-2222</a>

<!-- tel is a standard used by many apps -->
<a href="tel:1-650-111-2222">1-650-111-2222</a>
<a href="tel:16501112222">1-650-111-2222</a>
```
