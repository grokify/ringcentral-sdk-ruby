RingCentral SDK for Ruby
========================

[![Gem Version](https://badge.fury.io/rb/ringcentral_sdk.svg)](http://badge.fury.io/rb/ringcentral_sdk)
[![Build Status](https://img.shields.io/travis/grokify/ringcentral-sdk-ruby/master.svg)](https://travis-ci.org/grokify/ringcentral-sdk-ruby)
[![Coverage Status](https://coveralls.io/repos/grokify/ringcentral-sdk-ruby/badge.svg?branch=master)](https://coveralls.io/r/grokify/ringcentral-sdk-ruby?branch=master)
[![Dependency Status](https://gemnasium.com/grokify/ringcentral-sdk-ruby.svg)](https://gemnasium.com/grokify/ringcentral-sdk-ruby)
[![Code Climate](https://codeclimate.com/github/grokify/ringcentral-sdk-ruby/badges/gpa.svg)](https://codeclimate.com/github/grokify/ringcentral-sdk-ruby)
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/grokify/ringcentral-sdk-ruby/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/grokify/ringcentral-sdk-ruby/?branch=master)
[![Docs](https://img.shields.io/badge/docs-readthedocs-blue.svg)](http://ringcentral-sdk-ruby.readthedocs.org/)
[![Docs](https://img.shields.io/badge/docs-rubydoc-blue.svg)](http://www.rubydoc.info/gems/ringcentral_sdk/)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/grokify/ringcentral-sdk-ruby/master/LICENSE.txt)

## Table of contents

1. [Overview](#overview)
  1. [Included](#included)
  2. [To Do](#to-do)
2. [Documentation](#documentation)
3. [Installation](#installation)
4. [Usage](#usage)
  1. [Instantiation](#instantiation)
  1. [Authorization](#authorization)
    1. [Password Grant](#password-grant)
    1. [Authorization Code Grant](#authorization-code-grant)
  1. [API Requests](#api-requests)
    1. [SMS Example](#sms-example)
    2. [Fax Example](#fax-example)
  1. [Subscriptions](#subscriptions)
5. [Supported Ruby Versions](#supported-ruby-versions)
6. [Versioning](#versioning)
7. [Change Log](#change-log)
8. [Links](#links)
9. [Contributions](#contributions)
10. [License](#license)

## Overview

This is a Ruby SDK for the RingCentral for Developers Platform REST API (https://developers.ringcentral.com).

The core SDK objects follow the general design of the [official RingCentral SDKs](https://github.com/ringcentral). Additional functionality is provided for ease of use including request helpers and generalized OAuth2 support.

This SDK is an early stage library and subject to breaking changes.

### Included

* OAuth2 authorization code and password grant flows including token refresh via INTRIDEA `OAuth2::AccessToken`
* Generic API requests via `Faraday` client
* Subscriptions via `Pubnub` with auto-decryption
* Fax request helper to create `multipart/mixed` messages
* Stubbed HTTP request tests via `mocha`
* Docs via [Read the Docs](http://ringcentral-sdk-ruby.readthedocs.org/) and [RubyDoc](http://www.rubydoc.info/gems/ringcentral_sdk/)

### To Do

There are no major to do items at this time.

## Documentation

More documentation is available on [Read the Docs](http://ringcentral-sdk-ruby.readthedocs.org/)
and [RubyDoc](http://www.rubydoc.info/gems/ringcentral_sdk/). The documentation philosophy is to
use RubyDoc / YARD for brief documentation and code specific docs while using Read the Docs for
user guide / tutorial / FAQ style documentation.

In addition the documentation for this Ruby SDK, refer to the official RingCentral guides for
more information on individual API calls:

1. [API Developer and Reference Guide](https://developers.ringcentral.com/api-docs/latest/index.html) for information on specific APIs.
1. [API Explorer](http://ringcentral.github.io/api-explorer/)
1. [Dev Tutorial](http://ringcentral.github.io/tutorial/)

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

* `RingCentralSdk::RC_SERVER_PRODUCTION`
* `RingCentralSdk::RC_SERVER_SANDBOX`

```ruby
require 'ringcentral_sdk'

# Returns RingCentralSdk::Platform instance
rcsdk = RingCentralSdk.new(
  'myAppKey',
  'myAppSecret',
  RingCentralSdk::RC_SERVER_SANDBOX
)
```

### Authorization

#### Password Grant

The 2-legged OAuth 2.0 flow using a password grant is designed for server applications where the app and resource owners are the same.

```ruby
# Initialize using main phone number and extension number
rcsdk.authorize('myUsername', 'myExtension', 'myPassword')

# Initialize using user phone number without extension number
# Extension defaults to company admin extension
rcsdk.authorize('myUsername', nil, 'myPassword')
```

#### Authorization Code Grant

The 3-legged OAuth 2.0 flow using an authorization code grant is designed for web apps and public apps where authorization needs to be granted by a 3rd party resource owner.

```ruby
# Initialize SDK with OAuth redirect URI
rcsdk = RingCentralSdk.new(
  'myAppKey',
  'myAppSecret',
  RingCentralSdk::RC_SERVER_SANDBOX,
  {:redirect_uri => 'http://example.com/oauth'}
)
# Retrieve OAuth authorize url using default redirect URL
auth_url = rcsdk.authorize_url()
# Retrieve OAuth authorize url using override redirect URL
auth_url = rcsdk.authorize_url({
  :redirect_uri => 'my_registered_oauth_url', # optional override of default URL
  :display      => '', # optional: page|popup|touch|mobile, default 'page'
  :prompt       => '', # optional: sso|login|consent, default is 'login sso consent'
  :state        => '', # optional
  :brand_id     => ''  # optional: string|number
})
# Open browser window to authorization url and retrieve authorize code from redirect uri.
```

On your redirect page, you can exchange your authorization code for an access token using the following:

```ruby
code  = params['code'] # retrieve GET 'code' parameter in Sinatra
rcsdk.authorize_code(code)
```

For a complete working example, a demo Sinatra app is available in the scripts directory at [scripts/oauth2-sinatra](scripts/oauth2-sinatra).

#### Authentication Lifecycle

The platform class performs token refresh procedure automatically if needed. To save the access and refresh tokens between instances of the SDK, you can save and reuse the token as follows:

```ruby
# Retrieve and save access token when program is to be stopped
# `token` is an `OAuth2::AccessToken` object
token_hash = rcsdk.token.to_hash
```

After you have saved the token hash, e.g. as JSON, you can reload it in another instance of the SDK as follows:

```ruby
# Reuse token_hash in another SDK instance
rcsdk2 = RingCentralSdk.new(
  'myAppKey',
  'myAppSecret',
  RingCentralSdk::RC_SERVER_SANDBOX
)
# set_token() accepts a hash or OAuth2::AccessToken object
rcsdk2.set_token(token_hash)
```

Important! You have to manually maintain synchronization of SDK's between requests if you share authentication. When two simultaneous requests will perform refresh, only one will succeed. One of the solutions would be to have semaphor and pause other pending requests while one of them is performing refresh.

See [the authorization docs](http://ringcentral-sdk-ruby.readthedocs.org/en/latest/usage/authorization/Authorization/) for more info including token reuse.

### API Requests

Requests are made using the inclued Faraday client which you can
retrieve by calling `rcsdk.client` or using it directly.

```ruby
client = rcsdk.client
```

#### SMS Example

SMS and other requests can be easily sent directly without helpers.

```ruby
# SMS Example
response = rcsdk.client.post do |req|
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
that can be called by the `.request()` method of the Platform object. This enables the
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
response = rcsdk.request(fax)

# sending request via standard Faraday client
response = rcsdk.client.post do |req|
  req.url fax.url
  req.headers['Content-Type'] = fax.content_type
  req.body = fax.body
end
```

### Subscriptions

To make subscriptions with RingCentral, use the SDK object to create subscription Observer object and then add observers to it.

```ruby
sub = rcsdk.create_subscription()

sub.subscribe(['/restapi/v1.0/account/~/extension/~/presence'])

class MyObserver
  def update(message)
    puts "Subscription Message Received"
    puts JSON.dump(message)
  end
end

sub.add_observer(MyObserver.new())

sub.destroy() # end the subscription
```

## Supported Ruby Versions

This library supports and is [tested against](https://travis-ci.org/grokify/ringcentral-sdk-ruby) the following Ruby implementations:

* Ruby 2.2.3, 2.2.0
* Ruby 2.1.7, 2.1.0
* Ruby 2.0.0
* Ruby 1.9.3
* [JRuby](http://jruby.org/)
* [Rubinius](http://rubini.us/)

Note: Ruby 1.8.7 works except for subscription support which relies on the `pubnub` gem. If there is a need for 1.8.7 support, consider creating a GitHub issue so we can evalute creating a separate library for subscription handling.

## Versioning

This project is currently in development and the API can change. During initial development (Version 0.x.x), minor version changes will indicate either substantial feature inclusion or breaking changes.

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
