# Answering Rules - Call Forwarding

Organizations often wish to programmatically update the RingCentral extension Call Handling & Forwarding rules. This can be done using the RingCentral Connect Platform API as described below.

## Answering Rule Resource

Each RingCentral account has two answering rule resources, one for business hours and another for after hours. These can be configured by end-users using the RingCentral Online Account Portal under Extension Call Handling & Forwarding.

The API endpoints are as follows:

* `account/~/extension/~/answering-rule/business-hours-rule`
* `account/~/extension/~/answering-rule/after-hours-rule`

The answering rule resource can be retrieved via the following:

### Ruby SDK Request

```ruby
client.send_request(
  method: 'get',
  url: 'account/~/extension/~/answering-rule/business-hours-rule'
)
```

### HTTP Request

```http
GET /restapi/v1.0/account/11111111/extension/22222222/answering-rule/business-hours-rule HTTP/1.1
Accept: application/json
Authorization: Bearer MyAccessToken   
```

### HTTP Response

```json
HTTP/1.1 200 OK
Content-Type: application/json
{
    "uri": "http://platform.ringcentral.com/restapi/v1.0/account/11111111/extension/22222222/answering-rule/business-hours-rule",
    "id": "business-hours-rule",
    "type": "BusinessHours",
    "enabled": true,
    "schedule": {
        "ref": "BusinessHours"
    },
    "callHandlingAction": "ForwardCalls",
    "forwarding": {
        "notifyMySoftPhones": true,
        "notifyAdminSoftPhones": false,
        "softPhonesRingCount": 1,
        "ringingMode": "Sequentially",
        "rules": [
            {
                "index": 1,
                "ringCount": 4,
                "forwardingNumbers": [
                    {
                        "uri": "http://platform.ringcentral.com/restapi/v1.0/account/11111111/extension/22222222/forwarding-number/33333333",
                        "id": "33333333",
                        "phoneNumber": "+16505551212",
                        "label": "My Cisco SPA-303 Desk Phone"
                    }
                ]
            },
            {
                "index": 2,
                "ringCount": 8,
                "forwardingNumbers": [
                    {
                        "uri": "http://platform.ringcentral.com/restapi/v1.0/account/11111111/extension/22222222/forwarding-number/44444444",
                        "id": "44444444",
                        "phoneNumber": "+4155551212",
                        "label": "Home"
                    }
                ]
            },
            {
                "index": 3,
                "ringCount": 12,
                "forwardingNumbers": [
                    {
                        "uri": "http://platform.ringcentral.com/restapi/v1.0/account/11111111/extension/22222222/forwarding-number/55555555",
                        "id": "55555555",
                        "phoneNumber": "+12125551212",
                        "label": "Mobile"
                    }
                ]
            }
        ]
    },
    "greetings": [
        {
            "type": "Voicemail",
            "prompt": {
                "id": "0",
                "type": "message",
                "name": "No One Available"
            }
        },
        {
            "type": "Introductory"
        },
        {
            "type": "AudioWhileConnecting",
            "prompt": {
                "id": "6",
                "type": "music",
                "name": "Acoustic"
            }
        },
        {
            "type": "ConnectingMessage",
            "prompt": {
                "id": "3",
                "type": "message",
                "name": "Forward hold 1"
            }
        }
    ],
    "screening": "Never",
    "voicemail": {
        "enabled": true,
        "recipient": {
            "uri": "http://platform.ringcentral.com/restapi/v1.0/account/11111111/extension/22222222",
            "id": 22222222
        }
    }
}
```

## Updating the Forwarding Number Phone Number

The business and after hours rules can forward calls to a set of forwarding numbers. To update the phone number used, identify the forwarding number in the list of rules and then update the phone number of that resource using a HTTP PUT request to the endpoint updating the `phoneNumber` property.

An update can be written as follows:

### Ruby SDK Request

```ruby
client.send_request(
  method: 'put',
  url: 'account/11111111/extension/22222222/forwarding-number/33333333',
  body: {
    phoneNumber: '+16505551212'
  }
)
```

### HTTP Request

```http
PUT /restapi/v1.0/account/11111111/extension/22222222/forwarding-number/33333333 HTTP/1.1
Accept: application/json
Authorization: Bearer MyAccessToken
Content-Type: application/json

{
  "phoneNumber": "+16505551212"
}
```
