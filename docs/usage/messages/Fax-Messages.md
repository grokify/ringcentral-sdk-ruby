# Fax Messages

The RingCentral create fax message API consumes a `multipart/mixed` HTTP request.

A fax request helper is included in this SDK to make creating faxes easier.

**Notes**

1. Authorization occurs separately from the individual API requests. To do bulk requests, instantiate a `RingCentralSdk::Platform` object with `RingCentralSdk.new()` and then call the `.request()` method or `.client` Faraday client to make multiple requests using the OAuth `access_token`.
1. Request helpers are subclasses of `RingCentral::Helpers::Request` that provide the `method`, `url`, `content_type`, and `body` methods. These can be used by the Faraday client object or the helper class can be passed directly to the `sdk.request()` and `rcsdk.request()` methods.
1. The `rcsdk.request()` and `rcsdk.request()` methods only take request helpers as arguments and will raise an exception otherwise.

## Synopsis

```ruby
require 'ringcentral_sdk'

client = RingCentralSdk.new(
  'myAppKey', 'myAppSecret', RingCentralSdk::RC_SERVER_SANDBOX
)
client.authorize_password('myUsername', 'myExtension', 'myPassword')

# Simple text message
# Cover sheet "To" value defaults to Address Book Contact firstName + lastName
response = client.messages.fax.create(
  from: '+16505551212',
  to: '+14155551212',
  coverPageText: 'Check this out!',
  text: 'Hi there!'
)

# Cover sheet "To" value set to `to.name` attribute
response = client.messages.fax.create(
  from: '+16505551212',
  to: {
    phoneNumber: '+14155551212'
    name: 'John Doe'
  },
  text: 'Hi there!'
)

# Fax one or more files
client.messages.fax.create(
  to: '+14155551212',
  coverPageText: 'Check this out!',
  files: ['/path/to/my_file.pdf']
)
```

## HTTP Request Example: PDF with Octet Stream

This is an example request body for reference purposes.

```http
POST https://platform.ringcentral.com/restapi/v1.0/account/~/extension/~/fax HTTP/1.1
Authorization: Bearer U0pDMDFQMDFQQVMwMnxBQUFWZmY4ZXoxMlh
Accept: application/json
Content-Type: multipart/mixed; boundary=Boundary_9fzzogow8pxxub43x02zvcc5yg

--Boundary_9fzzogow8pxxub43x02zvcc5yg
Content-Type: application/json

{"to":[{"phoneNumber":"+16505551212"}],"faxResolution":"High","coverPageText":"RingCentral fax PDF example using Ruby SDK!"}
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

This is an example request body with Base64 encoding for reference purposes.

```http
POST https://platform.ringcentral.com/restapi/v1.0/account/~/extension/~/fax HTTP/1.1
Authorization: Bearer U0pDMDFQMDFQQVMwMnxBQUFWZmY4ZXoxMlh
Accept: application/json
Content-Type: multipart/mixed; boundary=Boundary_9j36hcowhyoi7683x02z56wq64

--Boundary_9j36hcowhyoi7683x02z56wq64
Content-Type: application/json

{"to":[{"phoneNumber":"+16505551212"}],"faxResolution":"High","coverPageText":"RingCentral fax PDF example using Ruby SDK!"}
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

## HTTP Response Example

Below is an example of a HTTP response from a create fax message request.

```json
{
  "uri" : "https://platform.devtest.ringcentral.com/restapi/v1.0/account/111111111/extension/222222222/message-store/333333333",
  "id" : 4444444444,
  "to" : [ {
    "phoneNumber" : "+16505551212",
    "location" : "Redwood City, CA"
  } ],
  "type" : "Fax",
  "creationTime" : "2015-05-09T16:11:58.000Z",
  "readStatus" : "Unread",
  "priority" : "Normal",
  "attachments" : [ {
    "id" : 4444444444,
    "uri" : "https://platform.devtest.ringcentral.com/restapi/v1.0/account/111111111/extension/222222222/message-store/333333333/content/4444444444",
    "type" : "RenderedDocument",
    "contentType" : "image/tiff"
  } ],
  "direction" : "Outbound",
  "availability" : "Alive",
  "messageStatus" : "Queued",
  "faxResolution" : "High",
  "faxPageCount" : 0,
  "lastModifiedTime" : "2015-05-09T16:11:58.519Z"
}
```

## Retrieve Fax Message Status

Initially, a fax message record will include property `messageStatus` set to `Queued` as shown above in the HTTP response example. To verify a fax has been set correctly poll the messaage `uri` provided for an updated `messageStatus`. Upon success, the `messageStatus` property will be updated to `"messageStatus" : "Sent"`.

One approach to handling this is to poll the message store API or the individual message end point to receive updates on `messageStatus`.

## Retrieve Fax Message

To down load a fax mssage from the message store, simply send a `GET` request to the message store URI and save the output as a binary file.

```ruby
res = rcsdk.client.get do |req|
  req.url 'account/111111111/extension/222222222/message-store/333333333/content/4444444444'
end

if res.status == 200
  File.open('path/to/myfile.pdf', 'wb') { |fp| fp.write(res.body) }
end
```

## New Fax Notification Event

A new incoming fax event via the Subscription API has the following format with the `newCount` attribute being incremented. An outgoing fax that is successfully sent will increment the `updatedCount` attribute.

```json
{
  "uuid": "11112222-3333-4444-5555-666677778888",
  "event": "/restapi/v1.0/account/~/extension/11112222/message-store",
  "timestamp": "2016-01-01T12:20:12.030Z",
  "body": {
    "extensionId": 11112222,
    "lastUpdated": "2016-01-01T12:20:05.471+0000",
    "changes": [
      {
        "type": "Fax",
        "newCount": 1,
        "updatedCount": 0
      }
    ]
  }
}
```

## FAQ

### Can I set the cover page "To" value?

Yes. The To attribute on the cover page is set two ways. If the `to.name` property is set in the request body, that value will be used on the cover page. If it is not set, the system will create a name by concatenating the `firstName` and `lastName` attributes of the address book contact with a matching `businessFax` number attribute.

### Can I send multiple files as one fax?

Yes you can. Just add each file as a MIME part. You can mix and match different MIME types. The Ruby fax helper has an `.add_file()` method that can be used in succession to add multiple files.

### What file types are supported for faxes?

RingCentral supports 29 file types including PDF, TIFF, DOCX, DOC, XLSX, XLS, RTF, HTML, XML and many more. These are listed in the [API Developer Guide](https://developers.ringcentral.com/api-docs/) along with the accepted MIME types.

### Is there a limit on fax file size?

Fax files are limited to 20 MB or 200 pages.

### Is providing a filename in the Content-Disposition header necessary?

A filename isn't necessary but if you provide one, it will be displayed in the [RingCentral Online Account Portal](https://service.ringcentral.com).

### How can I check the status of a fax message?

Faxes are queued by RingCentral and a successful response will include the property `"messageStatus" : "Queued"`. To verify a fax has been set correctly poll the messaage store `uri` property provided in the response for an updated `messageStatus`. Upon success, the `messageStatus` property will be updated to `"messageStatus" : "Sent"`.

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

### Why does my PDF fax have rendering issues.

Some faxes may use unsupported features and require flattening before sending them to the RingCentral API. Some PDF flattening tools include [GraphicsMagick](http://www.graphicsmagick.org/) / [ImageMagick](http://www.imagemagick.org/) and [Ghostscript](http://www.ghostscript.com/).

### Do I need multple sandbox accounts to support multiple fax numbers?

This depends on how you intend your application to work with the multiple fax numbers.

If you intend the multiple fax numbers to be owned by a single production RingCentral customer, then you only need a single Sandbox Account to represent the single Production Account. Within a single Sandbox (or Production) Account, you can create multiple Direct Numbers for fax that can be either Company Numbers (no extension) or a Direct Extension Number (associated with an extension).

If you intend the multiple fax numbers to be owned by and associated with multiple production RingCentral Customers, then you can create multiple Sandbox Accounts to represent the multiple Production Accounts.

### Is it possible to send a fax without the fax header line?

Not at this time. In the US, it is unlawful to send a fax with out the header line consisting of the following "the date and time it is sent and an identification of the business, other entity, or individual sending the message and the telephone number of the sending machine or of such business, other entity, or individual." This applies to all faxes based on content and delivery method (e-fax or traditional fax machines). This is specified in [US 47 CFR &#167; 68.318(d)](https://www.law.cornell.edu/cfr/text/47/68.318). For advertising specifically, this is also covered under the Telephone Consumer Protection Act of 1991 (TCPA), [47 USC &#167; 227(d)(1)(B)](https://www.law.cornell.edu/uscode/text/47/227).
