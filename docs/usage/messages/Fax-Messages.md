# Fax Messages

The RingCentral create fax message API consumes a `multipart/mixed` HTTP request.

A fax request helper is included in this SDK to make creating faxes easier.

## Faxing a Text Message

## Faxing a PDF or TIFF

### Faxing a PDF or TIFF

By default, creating a fax creates a `multipart/mixed` message with the body as a plain octet stream.

```ruby
require 'ringcentral_sdk'

response = RingCentralSdk::Sdk.new(
  'myAppKey', 'myAppSecret',
  RingCentralSdk::Sdk::RC_SERVER_SANDBOX,
  'myUsername', 'myExtension', 'myPassword'
).request(
  RingCentralSdk::Helpers::CreateFaxRequest.new(
    nil, # for authz user or { :account_id => '~', :extension_id => '~' }
    {
      :to            => [{ :phoneNumber => '+16505551212' }],
      :faxResolution => 'High',
      :coverPageText => 'RingCentral fax PDF example using Ruby!'
    },
    :file_name     => '/path/to/my_file.pdf'
  )
)
```

### Faxing a PDF or TIFF with Base 64 encoding

Base 64 encoding a message results in a larger message using more bandwith but
can be desirable for better debugging.

```ruby
require 'ringcentral_sdk'

response = RingCentralSdk::Sdk.new(
  'myAppKey', 'myAppSecret',
  RingCentralSdk::Sdk::RC_SERVER_SANDBOX,
  'myUsername', 'myExtension', 'myPassword'
).request(
  RingCentralSdk::Helpers::CreateFaxRequest.new(
    nil, # for authz user or { :account_id => '~', :extension_id => '~' }
    {
      :to            => [{ :phoneNumber => '+16505551212' }],
      :faxResolution => 'High',
      :coverPageText => 'RingCentral fax PDF example using Ruby!'
    },
    :file_name     => '/path/to/my_file.pdf',
    :encode_base64 => true
  )
)
```