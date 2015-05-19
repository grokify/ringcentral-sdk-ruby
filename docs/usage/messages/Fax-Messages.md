# Fax Messages

The RingCentral create fax message API consumes a `multipart/mixed` HTTP request.

A fax request helper is included in this SDK to make creating faxes easier.

**Note:** The `sdk.request()` and `sdk.platform.request()` methods only take request helpers as arguments. Request helpers are subclasses of `RingCentral::Helpers::Request` and provide the `method`, `url`, `content_type`, and `body` methods. The latter three of which can be sent directly to the Faraday client object.

## Faxing a Text Message

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
      :coverPageText => 'RingCentral fax text example using Ruby!'
    },
    :text     => 'RingCentral fax text example using Ruby!'
  )
)
```

## Faxing a PDF or TIFF

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

## Faxing a PDF or TIFF with Base 64 Encoding

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
      :coverPageText => 'RingCentral fax TIFF example using Ruby!'
    },
    :file_name     => '/path/to/my_file.tif',
    :encode_base64 => true
  )
)
```

## HTTP Request Example: PDF with Octet Stream

```http
POST https://platform.ringcentral.com/restapi/v1.0/account/~/extension/~/fax HTTP/1.1
Authorization: Bearer U0pDMDFQMDFQQVMwMnxBQUFWZmY4ZXoxMlh
Accept: application/json
Content-Type: multipart/mixed; boundary=Boundary_9fzzogow8pxxub43x02zvcc5yg

--Boundary_9fzzogow8pxxub43x02zvcc5yg
Content-Type: application/json

{"to":[{"phoneNumber":"+16505626570"}],"faxResolution":"High","coverPageText":"RingCentral fax PDF example using Ruby SDK!"}
--Boundary_9fzzogow8pxxub43x02zvcc5yg
Content-Type: application/pdf
Content-Disposition: attachment; filename="test_file.pdf"

%PDF-1.3
%?????????
4 0 obj
<< /Length 5 0 R /Filter /FlateDecode >>
stream
[...]
0000024228 00000 n 
0000024265 00000 n 
trailer
<< /Size 27 /Root 12 0 R /Info 1 0 R /ID [ <48712ae2bdffa879f883d08f491ab571>
<48712ae2bdffa879f883d08f491ab571> ] >>
startxref
24427
%%EOF

--Boundary_9fzzogow8pxxub43x02zvcc5yg--
```

## HTTP Request Example: PDF with Base 64 Encoding

```http
POST https://platform.ringcentral.com/restapi/v1.0/account/~/extension/~/fax HTTP/1.1
Authorization: Bearer U0pDMDFQMDFQQVMwMnxBQUFWZmY4ZXoxMlh
Accept: application/json
Content-Type: multipart/mixed; boundary=Boundary_9j36hcowhyoi7683x02z56wq64

--Boundary_9j36hcowhyoi7683x02z56wq64
Content-Type: application/json

{"to":[{"phoneNumber":"+16505626570"}],"faxResolution":"High","coverPageText":"RingCentral fax PDF example using Ruby SDK!"}
--Boundary_9j36hcowhyoi7683x02z56wq64
Content-Type: application/pdf
Content-Transfer-Encoding: base64

JVBERi0xLjMKJcTl8uXrp/Og0MTGCjQgMCBvYmoKPDwgL0xlbmd0aCA1IDAg
[...]
ODcxMmFlMmJkZmZhODc5Zjg4M2QwOGY0OTFhYjU3MT4gXSA+PgpzdGFydHhy
ZWYKMjQ0MjcKJSVFT0YK

--Boundary_9j36hcowhyoi7683x02z56wq64--
```