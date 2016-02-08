# Generic HTTP Requests

The SDK provides access to a HTTP client and generic requests to support the wide number of APIs supported by the RingCentral Connect Platform. The HTTP client and generic request processor will automatically manage OAuth access token refresh transparently.

* The HTTP Client is a Faraday client.
* The generic requests are sub-classes of `RingCentralSdk::REST::Request::Base`. A generic request subclass, `RingCentral::REST::Request::Simple` to simply API calls. A fax subclasses is also provided to make creating `multipart/mixed` requests easier.

## HTTP Client

To make generic API requests, use included `Faraday` client which can be accessed via `client.http`. The client automatically adds the correct access token to the HTTP request and handles OAuth token refresh using the `OAuth` gem.

```ruby
http = client.http
```

Faraday request middleware has been loaded for the following:

* `:oauth2_refresh`
* `:json`
* `:url_encoded`

Faraday response middleware is loaded for the following:

* `:json`

An example SMS request is presented below:

```ruby
# SMS using Faraday
response = client.http.post do |req|
  req.url 'account/~/extension/~/sms'
  req.headers['Content-Type'] = 'application/json'
  req.body = {
    from: {phoneNumber: '+16505551212'},
    to: [ {phoneNumber: '+14155551212'} ],
    text: 'Hi there!'
  }
end
```

## RingCentralSDK Request Subclasses

In addition to providing access to the Faraday client, the SDK also provides a Request base class that can be used to construct more complicated requests.

| Class name | Description |
|------------|-------------|
| `RingCentralSDK::REST::Request::Base` | Base class |
| `RingCentralSDK::REST::Request::Simple` | Generic helper class |
| `RingCentralSDK::REST::Request::Fax` | Fax helper class |

### Base class interface

| Class name | Type | Description |
|------------|------|-------------|
| `method` | enum String [`get`, `post`, `put`, `delete`] |
| `url` | String |
| `params` | Hash | query parameters |
| `headers` | Hash |
| `body` | String or Hash | Hash for JSON |
| `content_type` | String | convenience method |

### Simple Request Class

```ruby
request = RingCentralSdk::REST::Request::Simple.new(
  url: 'account/~/extension/~/message-store',
  params: {
    direction: 'Inbound',
    messageType: 'SMS'
  }
)

response = client.send_request request
```
