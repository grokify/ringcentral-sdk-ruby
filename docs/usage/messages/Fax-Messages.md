# Fax Messages

The RingCentral create fax message API consumes a `multipart/mixed` HTTP request.

A fax request helper is included in this SDK to make creating faxes easier.

**Notes**

1. Authorization occurs separately from the individual API requests. To do bulk requests, instantiate a `RingCentralSdk::Sdk` object and then call the `.request()` method or `.platform.client` Faraday client to make multiple requests using the OAuth `access_token`.
1. Request helpers are subclasses of `RingCentral::Helpers::Request` that provide the `method`, `url`, `content_type`, and `body` methods. These can be used by the Faraday client object or the helper class can be passed directly to the `sdk.request()` and `sdk.platform.request()` methods.
1. The `sdk.request()` and `sdk.platform.request()` methods only take request helpers as arguments and will raise an exception otherwise.

## Faxing a Text Message

```ruby
require 'ringcentral_sdk'

response = RingCentralSdk::Sdk.new(
  'myAppKey', 'myAppSecret', RingCentralSdk::Sdk::RC_SERVER_SANDBOX,
  'myUsername', 'myExtension', 'myPassword'
).request(
  RingCentralSdk::Helpers::CreateFaxRequest.new(
    nil, # for authz user or { :account_id => '~', :extension_id => '~' }
    {
      :to            => '+16505551212', # inflates to [{ :phoneNumber => '+16505551212' }],
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
  'myAppKey', 'myAppSecret', RingCentralSdk::Sdk::RC_SERVER_SANDBOX,
  'myUsername', 'myExtension', 'myPassword'
).request(
  RingCentralSdk::Helpers::CreateFaxRequest.new(
    nil, # for authz user or { :account_id => '~', :extension_id => '~' }
    {
      :to            => { :phoneNumber => '+16505551212' }, # inflates to [{ :phoneNumber => '+16505551212' }],
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
  'myAppKey', 'myAppSecret', RingCentralSdk::Sdk::RC_SERVER_SANDBOX,
  'myUsername', 'myExtension', 'myPassword'
).request(
  RingCentralSdk::Helpers::CreateFaxRequest.new(
    nil, # for authz user or { :account_id => '~', :extension_id => '~' }
    {
      :to            => [{ :phoneNumber => '+16505551212' }],
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
Content-Disposition: attachment; filename="test_file.pdf"

JVBERi0xLjMKJcTl8uXrp/Og0MTGCjQgMCBvYmoKPDwgL0xlbmd0aCA1IDAg
[...]
ODcxMmFlMmJkZmZhODc5Zjg4M2QwOGY0OTFhYjU3MT4gXSA+PgpzdGFydHhy
ZWYKMjQ0MjcKJSVFT0YK

--Boundary_9j36hcowhyoi7683x02z56wq64--
```

## FAQ

### Can I send multiple files as one fax?

Yes you can. Just add each file as a MIME part. You can mix and match different MIME types. The Ruby fax helper has an `.add_file()` method that can be used in succession to add multiple files.

### What file types are supported for faxes?

RingCentral supports 29 file types including PDF, TIFF, DOCX, DOC, XLSX, XLS, RTF, HTML, XML and many more. These are listed in the [API Developer Guide](https://developers.ringcentral.com/api-docs/) along with the accepted MIME types.

### Is providing a filename in the Content-Disposition header necessary?

A filename isn't necessary but if you provide one, it will be displayed in the [RingCentral Online Account Portal](https://service.ringcentral.com).

### Why can the faxPageCount change?

When a fax request is first submitted the `faxPageCount` is set to 0 when when `messageStatus` is set to `Queued` because the fax hasn't been rendered yet so the number of pages haven't been counted. When the fax is successfully rendered and sent with `messageStatus` set to `Sent` the `faxPageCount` will be properly populated. In the event that the message is not successfully sent and the `messageStatus` is set to `SendingFailed`, the `faxPageCount` property may or may not be sent depending on the type of failure.

### How can I view sent faxes in the Service Web Portal?

Yes, faxes sent via the API can be viewed in the Service Web Portal (https://service.ringcentral.com) in both `Messages > Sent Items` and in the `Call Log`. The rendered fax documents can be downloaded from `Messages > Sent Items`.

### How can I retrieve a sent fax via API?

When sending a fax via the API, the fax message `messageId` and rendered fax `attachmentId` can be used in the message store end points to retrieve the message information or attachment.

### Will retrieving a rendered fax attachment change the read status?

Retrieving a fax attachment file via the API will not change the read status to `Read` from `Unread`. This is desirable as retrieving the fax document may be for archival and other purposes that should not indicate the fax was read. To change the status use the Update Message API call.

### Is it possible to find out why a fax failed?

If a fax transmission fails, the reason is reported in the Call Log Record's `result` property. It is also presented in the Service Web Portal.

### Do I need multple sandbox accounts to support multiple fax numbers?

This depends on how you intend your application to work with the multiple fax numbers.

If you intend the multiple fax numbers to be owned by a single production RingCentral customer, then you only need a single Sandbox Account to represent the single Production Account. Within a single Sandbox (or Production) Account, you can create multiple Direct Numbers for fax that can be either Company Numbers (no extension) or a Direct Extension Number (associated with an extension).

If you intend the multiple fax numbers to be owned by and associated with multiple production RingCentral Customers, then you can create multiple Sandbox Accounts to represent the multiple Production Accounts.
