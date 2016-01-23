# HTTP Client

To make generic API requests, use included `Faraday` client which can be accessed via `rcsdk.client`. The client automatically adds the correct access token to the HTTP request and handles OAuth token refresh using the `OAuth` gem.

```ruby
client = rcsdk.client
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
response = rcapi.client.post do |req|
  req.url 'account/~/extension/~/sms'
  req.headers['Content-Type'] = 'application/json'
  req.body = {
    :from =>   { :phoneNumber => '+16505551212' },
    :to   => [ { :phoneNumber => '+14155551212'} ],
    :text => 'Hi there!'
  }
end
```