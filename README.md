RingCentral SDK
===============

[![Build Status](https://img.shields.io/travis/grokify/ringcentral-sdk-ruby/master.svg?style=flat-square)](https://travis-ci.org/grokify/ringcentral-sdk-ruby)
[![Documentation](https://img.shields.io/badge/documentation-rubydoc-blue.svg?style=flat-square)](http://www.rubydoc.info/gems/ringcentral_sdk/)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://raw.githubusercontent.com/grokify/ringcentral-sdk-ruby/master/LICENSE.txt)
[![Coverage Status](https://coveralls.io/repos/grokify/ringcentral-sdk-ruby/badge.svg?branch=master)](https://coveralls.io/r/grokify/ringcentral-sdk-ruby?branch=master)

This is an unofficial Ruby SDK for the RingCentral Connect Platform REST API (https://developers.ringcentral.com).

The core SDK objects follow the general design of the [official RingCentral SDKs](https://github.com/ringcentral). The SDK helper additions are included to make it easier to interact with features of the API.

This SDK is an early stage library and subject to breaking changes.

## Included

* OAuth authorization
* Faraday client with OAuth bearer token handling
* Fax helper to create multipart/mixed messages

## To Do

The following items are still needed for this SDK. Contributions are most welcome.

* Token refresh
* Subscriptions
* Additional tests

Installation
============

## Via Bundler

Add this line to your application's Gemfile:

```ruby
gem 'ringcentral_sdk'
```

And then execute:

```sh
$ bundle
```

## Via RubyGems

```sh
$ gem install ringcentral_sdk
```

Usage
=====

## Initialization

The RingCentral server URLs can be populated manually or via the included constants:

* `RingCentralSdk::Sdk::RC_SERVER_PRODUCTION`
* `RingCentralSdk::Sdk::RC_SERVER_SANDBOX`

```ruby
## Initialization ##

require 'ringcentral_sdk'

rcsdk = RingCentralSdk::Sdk.new(
  "myAppKey",
  "myAppSecret",
  RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)
platform = rcsdk.platform
```

## Authentication

```ruby
# Initialize using user phone number without extension number

platform.authorize("myUsername", nil, "myPassword")

# Initialize using main phone number and extension number

platform.authorize("myUsername", "myExtension", "myPassword")
```

## Creating Requests

Requests are made using the inclued Faraday client.

```ruby
client = rcsdk.platform.client
```

## Create SMS Message

SMS and other requests can be easily sent directly without helpers.

```ruby
# Send SMS - POST request

response = client.post do |req|
  req.url 'account/~/extension/~/sms'
  req.headers['Content-Type'] = 'application/json'
  req.body = {
    :from =>   { :phoneNumber => '16505551212' },
    :to   => [ { :phoneNumber => '14155551212'} ],
    :text => 'RingCentral SMS demo using Ruby!'
  }
end
```

## Create Fax Message

A fax helper is included that can be used to create the `multipart/mixed` HTTP request.

This consists of instantiating a fax helper object and then executing a Faraday POST request.

### 1) Fax Helper for Text Message

```ruby
fax = RingCentralSdk::Helpers::CreateFaxRequest.new(
  { account_id => '~', extension_id => '~' }, # Can be nil or {} for defaults '~'
  {
    # phone numbers are in E.164 format with or without leading '+'
    :to            => [{ :phoneNumber => '+16505551212' }],
    :faxResolution => 'High',
    :coverPageText => 'RingCentral fax text demo using Ruby!'
  },
  :text => 'RingCentral Fax via Ruby!'
)
# send the fax using Faraday as shown below
```

### 2) Fax Helper for File as Raw Bytes (e.g. PDF or TIFF)

Sending a file as a plain octet-stream is useful in production as it can decrease file size by 30%.

```ruby

fax = RingCentralSdk::Helpers::CreateFaxRequest.new(
  { account_id => '~', extension_id => '~' }, # Can be nil or {} for defaults '~'
  {
    # phone numbers are in E.164 format with or without leading '+'
    :to            => [{ :phoneNumber => '+16505551212' }],
    :faxResolution => 'High',
    :coverPageText => 'RingCentral fax PDF demo using Ruby!'
  },
  :file_name     => '/path/to/my_file.pdf'
)
# send the fax using Faraday as shown below
```

### 3) Fax Helper for File Base64 Encoded (e.g. PDF or TIFF)

Sending a file base64 encoded is useful for debugging purposes as the file can be copy and pasted.

```ruby
fax = RingCentralSdk::Helpers::CreateFaxRequest.new(
  { account_id => '~', extension_id => '~' }, # Can be nil or {} for defaults '~'
    {
    # phone numbers are in E.164 format with or without leading '+'
    :to            => [{ :phoneNumber => '+16505551212' }],
    :faxResolution => 'High',
    :coverPageText => 'RingCentral fax TIFF base64 demo using Ruby!'
  },
  :file_name     => '/path/to/my_file.tif',
  :base64_encode => true
)
# send the fax using Faraday as shown below
```

### Sending the fax

```ruby
response = client.post do |req|
  req.url fax.url
  req.headers['Content-Type'] = fax.content_type
  req.body = fax.body
end
```

Change Log
==========

- **2015-05-13**: 0.0.3
  - Initial public release

Links
=====

Project Repo

* https://github.com/grokify/ringcentral-sdk-ruby

RingCentral API Docs

* https://developers.ringcentral.com/library.html

RingCentral API Explorer

* http://ringcentral.github.io/api-explorer

RingCentral Official SDKs

* https://github.com/ringcentral

Problems, Comments, Suggestions?
================================

All of the above are most welcome. johncwang@gmail.com

License
=======

RingCentral SDK is available under an MIT-style license. See {file:LICENSE.txt} for details.

RingCentral SDK &copy; 2015 by John Wang