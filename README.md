RingCentral SDK
===============

[![Gem Version](https://badge.fury.io/rb/ringcentral_sdk.svg)](http://badge.fury.io/rb/ringcentral_sdk)
[![Build Status](https://img.shields.io/travis/grokify/ringcentral-sdk-ruby/master.svg)](https://travis-ci.org/grokify/ringcentral-sdk-ruby)
[![Code Climate](https://codeclimate.com/github/grokify/ringcentral-sdk-ruby/badges/gpa.svg)](https://codeclimate.com/github/grokify/ringcentral-sdk-ruby)
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
# Initialize using user phone number without extension number

platform.authorize("myUsername", nil, "myPassword")

# Initialize using main phone number and extension number

platform.authorize("myUsername", "myExtension", "myPassword")
```

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

## Change Log

- **2015-05-31**: 0.1.2
  - Add Ruby 1.8.7 support
  - Add CI for Ruby 2.2.0 & 2.1.6: 2.2.2, 2.2.0, 2.1.6, 2.1.0, 2.0.0, 1.9.3, 1.8.7
- **2015-05-31**: 0.1.1
  - Add Ruby 2.2.2 support
- **2015-05-31**: 0.1.0
  - Add OAuth token refresh
  - Add OAuth2::AccessToken support
  - Add Code Climate hook
- **2015-05-19**: 0.0.4
  - Add RingCentralSdk::Helpers::Request as request helpers base class 
  - Add sdk.request() and platform.request() methods added to handle request helpers
  - Fax helper uses file mime-type in preference to generic octet-stream
  - Initial mkdocs and Read the Docs effort added
  - Travis CI and Coveralls hooks added
- **2015-05-14**: 0.0.3
  - First public release
- **2015-03-08**: 0.0.2
  - Convert methods from camelCase to under_scores
- **2015-03-07**: 0.0.1
  - Initial release

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

RingCentral SDK is available under an MIT-style license. See {file:LICENSE.txt} for details.

RingCentral SDK &copy; 2015 by John Wang