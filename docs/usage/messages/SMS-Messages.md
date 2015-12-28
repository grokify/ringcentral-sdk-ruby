# SMS

Sending and receiving SMS is a core capability of RingCentral. Features include UTF-8 and long concatenated message support.

## Sending a SMS

SMS requests can be easily sent directly without helpers.

```ruby
# SMS Example

response = rcsdk.client.post do |req|
  req.url 'account/~/extension/~/sms'
  req.headers['Content-Type'] = 'application/json'
  req.body = {
    :from =>   { :phoneNumber => '16505551212' },
    :to   => [ { :phoneNumber => '14155551212'} ],
    :text => 'RingCentral SMS demo using Ruby!'
  }
end
```

## Retrieving a List of Valid SMS Sending Numbers

When building an application that sends SMS it is useful to retrieve a list of SMS numbers to pre-select the `from` phone number. This can be done using the `extension/phone-number` endpoint and then selecting the phone numbers with the `SmsSender` feature.

To retrieve a list of phone numbers, make a `GET` request to the `extension/phone-number` endpoint as follows:

```ruby
# Phone Number Example

response = rcsdk.client.get do |req|
  req.url 'account/~/extension/~/phone-number'
end
```

This will return a list of phone numbers assigned the extension as follows:

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