RingCentral SDK
===============

[![Gem Version](https://badge.fury.io/rb/ringcentral_sdk.svg)](http://badge.fury.io/rb/ringcentral_sdk)
[![Build Status](https://img.shields.io/travis/grokify/ringcentral-sdk-ruby/master.svg)](https://travis-ci.org/grokify/ringcentral-sdk-ruby)
[![Code Climate](https://codeclimate.com/github/grokify/ringcentral-sdk-ruby/badges/gpa.svg)](https://codeclimate.com/github/grokify/ringcentral-sdk-ruby)
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/grokify/ringcentral-sdk-ruby/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/grokify/ringcentral-sdk-ruby/?branch=master)
[![Coverage Status](https://coveralls.io/repos/grokify/ringcentral-sdk-ruby/badge.svg?branch=master)](https://coveralls.io/r/grokify/ringcentral-sdk-ruby?branch=master)
[![Docs](https://img.shields.io/badge/docs-readthedocs-blue.svg)](http://ringcentral-sdk-ruby.readthedocs.org/)
[![Docs](https://img.shields.io/badge/docs-rubydoc-blue.svg)](http://www.rubydoc.info/gems/ringcentral_sdk/)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/grokify/ringcentral-sdk-ruby/master/LICENSE.txt)

## Table of contents

1. [Overview](#overview)
  1. [Included](#included)
  2. [To Do](#to-do)
2. [Documentation](#documentation)
3. [Installation](#installation)
2. [Usage](#usage)
  1. [Instantiation](#instantiation)
  1. [Authorization](#authorization)
  1. [API Requests](#api-requests)
    1. [SMS Example](#sms-example)
    2. [Fax Example](#fax-example)
5. [Change Log](#change-log)
6. [Links](#links)
7. [Contributions](#contributions)
8. [License](#license)

## Overview

This is an unofficial Ruby SDK for the RingCentral for Developers Platform REST API (https://developers.ringcentral.com).

The core SDK objects follow the general design of the [official RingCentral SDKs](https://github.com/ringcentral). Additional functionality is provided for ease of use including request helpers and generalized OAuth2 support.

This SDK is an early stage library and subject to breaking changes.

### Included

* OAuth2 authorization & token refresh via INTRIDEA `OAuth2::AccessToken`
* Generic API requests handled via `Faraday` client
* Fax request helper to create `multipart/mixed` messages
* Docs via [Read the Docs](http://ringcentral-sdk-ruby.readthedocs.org/) and [RubyDoc](http://www.rubydoc.info/gems/ringcentral_sdk/)

### To Do

The following items are still needed for this SDK. Contributions are most welcome.

* Subscriptions
* Mock tests

## Documentation

More documentation is available on [Read the Docs](http://ringcentral-sdk-ruby.readthedocs.org/)
and [RubyDoc](http://www.rubydoc.info/gems/ringcentral_sdk/). The documentation philosophy is to
use RubyDoc / YARD for brief documentation and code specific docs while using Read the Docs for
user guide / tutorial / FAQ style documentation.

In addition the documentation for this Ruby SDK, refer to the official RingCentral guides for
more information on individual API calls:

1. [API Developer and Reference Guide](https://developers.ringcentral.com/api-docs/latest/index.html) for information on specific APIs.
1. [API Explorer](http://ringcentral.github.io/api-explorer/)
1. [CTI Tutorial](http://ringcentral.github.io/cti-tutorial/)

## Installation

### Via Bundler

Add this line to your application's Gemfile:

```ruby
gem 'ringcentral_sdk'
```

And then execute:

```sh
$ bundle
```

### Via RubyGems

```sh
$ gem install ringcentral_sdk
```

## Usage

This provides a very basic guide to using the SDK. Please use the following resources for more information:

1. [API Developer and Reference Guide](https://developers.ringcentral.com/api-docs/latest/index.html)

### Instantiation

The RingCentral server URLs can be populated manually or via the included constants:

* `RingCentralSdk::Sdk::RC_SERVER_PRODUCTION`
* `RingCentralSdk::Sdk::RC_SERVER_SANDBOX`

```ruby
require 'ringcentral_sdk'

rcsdk = RingCentralSdk::Sdk.new(
  "myAppKey",
  "myAppSecret",
  RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)
platform = rcsdk.platform
```

### Authorization

```ruby
# Initialize using main phone number and extension number
platform.authorize("myUsername", "myExtension", "myPassword")

# Initialize using user phone number without extension number
# Extension defaults to company admin extension
platform.authorize("myUsername", nil, "myPassword")
```

#### Authentication Lifecycle

The platform class performs token refresh procedure automatically if needed. To save the access and refresh tokens between instances of the SDK, you can save and reuse the token as follows:

```ruby
# Retrieve and save access token when program is to be stopped
# `token` is an `OAuth2::AccessToken` object
token_hash = rcsdk.platform.token.to_hash
```

After you have saved the token hash, e.g. as JSON, you can reload it in another instance of the SDK as follows:

```ruby
# Reuse token_hash in another SDK instance
rcsdk2 = RingCentralSdk::Sdk.new(
  "myAppKey",
  "myAppSecret",
  RingCentralSdk::Sdk::RC_SERVER_SANDBOX
)
# set_token() accepts a hash or OAuth2::AccessToken object
rcsdk2.platform.set_token(token_hash)
```

Important! You have to manually maintain synchronization of SDK's between requests if you share authentication. When two simultaneous requests will perform refresh, only one will succeed. One of the solutions would be to have semaphor and pause other pending requests while one of them is performing refresh.

See [the authorization docs](http://ringcentral-sdk-ruby.readthedocs.org/en/latest/usage/authorization/Authorization/) for more info including token reuse.

### API Requests

Requests are made using the inclued Faraday client which you can
retrieve by calling `rcsdk.platform.client` or using it directly.

```ruby
client = rcsdk.platform.client
```

#### SMS Example

SMS and other requests can be easily sent directly without helpers.

```ruby
# SMS Example
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

#### Fax Example

Request helpers are subclasses of `RingCentralSdk::Helpers::Request` and provide standard methods
that can be called by the `.request()` method of the SDK and Platform objects. This enables the
requisite information for Faraday to be generated in a standard way.

To create your own request helpers, please take a look at the fax one shown below:

The fax helper is included to help create the `multipart/mixed` HTTP request. This consists of
instantiating a fax helper object and then executing a Faraday POST request. The helper can then
be used with the standard faraday client or helper `.request()` method that takes the request
helper object in its entirety.

```ruby
# Fax example using request helper
fax = RingCentralSdk::Helpers::CreateFaxRequest.new(
  nil, # auto-inflates to [{:account_id => '~', :extension_id => '~'}]
  {
    # phone numbers are in E.164 format with or without leading '+'
    :to            => [{ :phoneNumber => '+16505551212' }],
    :coverPageText => 'RingCentral fax PDF demo using Ruby!'
  },
  :file_name     => '/path/to/my_file.pdf'
)

# sending request via request helper methods
response = sdk.request(fax)
response = sdk.platform.request(fax)

# sending request via standard Faraday client
response = client.post do |req|
  req.url fax.url
  req.headers['Content-Type'] = fax.content_type
  req.body = fax.body
end
```

## Versioning

This project is currently in development and the API can change. During development (Version 0.x.x), breaking changes will be indicated by a change in minor version (second number).

Once the project is version 1.0.0 or above, it will use [semantic versioning](http://semver.org/). At this time, breaking changes will be indicated by a change in major version.

## Change Log

See [CHANGELOG.md](CHANGELOG.md)

## Links

Project Repo

* https://github.com/grokify/ringcentral-sdk-ruby

RingCentral API Docs

* https://developers.ringcentral.com/library.html

RingCentral API Explorer

* http://ringcentral.github.io/api-explorer

RingCentral Official SDKs

* https://github.com/ringcentral

## Contributions

Any reports of problems, comments or suggestions are most welcome.

Please report these on [Github](https://github.com/grokify/ringcentral-sdk-ruby)

## License

RingCentral SDK is available under an MIT-style license. See [LICENSE.txt](LICENSE.txt) for details.

RingCentral SDK &copy; 2015 by John Wang