RingCentral SDK for Ruby
========================

[![Gem Version][gem-version-svg]][gem-version-link]
[![Build Status][build-status-svg]][build-status-link]
[![Coverage Status][coverage-status-svg]][coverage-status-link]
[![Dependency Status][dependency-status-svg]][dependency-status-link]
[![Code Climate][codeclimate-status-svg]][codeclimate-status-link]
[![Scrutinizer Code Quality][scrutinizer-status-svg]][scrutinizer-status-link]
[![Downloads][downloads-svg]][downloads-link]
[![Docs][docs-readthedocs-svg]][docs-readthedocs-link]
[![Docs][docs-rubydoc-svg]][docs-rubydoc-link]
[![License][license-svg]][license-link]

## Table of contents

1. [Overview](#overview)
2. [Documentation](#documentation)
3. [Installation](#installation)
4. [Usage](#usage)
  1. [Instantiation](#instantiation)
  1. [Authorization](#authorization)
    1. [Password Grant](#password-grant)
    1. [Authorization Code Grant](#authorization-code-grant)
    1. [Token Reuse](#token-reuse)
  1. [API Requests](#api-requests)
    1. [Generic HTTP Requests](#generic-http-requests)
    2. [SMS Example](#sms-example)
    3. [Fax Example](#fax-example)
  1. [Advanced Use Cases](#advanced-use-cases)
5. [Supported Ruby Versions](#supported-ruby-versions)
6. [Releases](#releases)
  1. [Versioning](#versioning)
  1. [Change Log](#change-log)
8. [Links](#links)
9. [Contributions](#contributions)
10. [License](#license)

## Overview

A library for using the [RingCentral REST API](https://developers.ringcentral.com). [Click here to read the full documentation](http://ringcentral-sdk-ruby.readthedocs.org/).

## Documentation

Full documentation and resources are available at:

1. [Ruby SDK Developer Guide](http://ringcentral-sdk-ruby.readthedocs.org/) - Read the Docs
2. [Ruby SDK Reference Guide](http://www.rubydoc.info/gems/ringcentral_sdk/) - RubyDoc.info

For API information, see the official RingCentral resources:

1. [API Developer and Reference Guide](https://developers.ringcentral.com/api-docs/latest/index.html)
1. [API Explorer](https://developer.ringcentral.com/api-explorer/)
1. [CTI Tutorial](http://ringcentral.github.io/tutorial/)

## Installation

### Via Bundler

Add 'ringcentral_sdk' to Gemfile and then run `bundle`:

```sh
$ echo "gem 'ringcentral_sdk'" >> Gemfile
$ bundle
```

### Via RubyGems

```sh
$ gem install ringcentral_sdk
```

## Usage

### Instantiation and Authorization

How you instantiate the SDK can depend on whether you use OAuth 2.0 password grant or the authorization code grant which are both described here.

It is also necessary to specify your RingCentral API end point URL which are included constants:

* `RingCentralSdk::RC_SERVER_PRODUCTION`
* `RingCentralSdk::RC_SERVER_SANDBOX`

#### Password Grant

The OAuth 2.0 resource owner password grant flow is designed for server applications where the app and resource owners are the same.

```ruby
require 'ringcentral_sdk'

# Returns RingCentralSdk::Platform instance
client = RingCentralSdk::REST::Client.new(
  'myAppKey',
  'myAppSecret',
  RingCentralSdk::RC_SERVER_SANDBOX
)

# extension will default to company admin extension if not provided
client.authorize_password('myUsername', 'myExtension', 'myPassword')
```

#### Authorization Code Grant

The OAuth 2.0 authorization code grant is designed for where authorization needs to be granted by a 3rd party resource owner.

Using the default authorization URL:

```ruby
# Initialize SDK with OAuth redirect URI
client = RingCentralSdk::REST::Client.new(
  'myAppKey',
  'myAppSecret',
  RingCentralSdk::RC_SERVER_SANDBOX,
  {:redirect_uri => 'http://example.com/oauth'}
)

# Retrieve OAuth authorize url using default redirect URL
auth_url = client.authorize_url()
```

On your redirect page, you can exchange your authorization code for an access token using the following:

```ruby
code  = params['code'] # e.g. using Sinatra to retrieve code param in Redirect URI
client.authorize_code(code)
```

More information on the authorization code flow:

1. [Full documentation](http://ringcentral-sdk-ruby.readthedocs.org/en/latest/usage/authorization/Authorization/#authorization-code-grant)
2. [Sinatra example](scripts/oauth2-sinatra)

#### Token Reuse

The platform class performs token refresh procedure automatically if needed. To save the access and refresh tokens between instances of the SDK, you can save and reuse the token as follows:

```ruby
# Access `OAuth2::AccessToken` object as hash
token_hash = client.token.to_hash
```

You can reload the token hash in another instance of the SDK as follows:

```ruby
# set_token() accepts a hash or OAuth2::AccessToken object
client.set_token(token_hash)
```

Important! You have to manually maintain synchronization of SDK's between requests if you share authentication. When two simultaneous requests will perform refresh, only one will succeed. One of the solutions would be to have semaphor and pause other pending requests while one of them is performing refresh.

See [the authorization docs](http://ringcentral-sdk-ruby.readthedocs.org/en/latest/usage/authorization/Authorization/) for more info including token reuse.

### API Requests

API requests can be made via the included `Faraday` client or `RingCentralSdk::Helpers::Request` subclasses. These are described below.

#### Generic HTTP Requests

To make generic API requests, use included `Faraday` client which can be accessed via `client.http`. The client automatically adds the correct access token to the HTTP request and handles OAuth token refresh using the `OAuth` gem.

This is useful to access many API endpoints which do not have custom wrappers and for debugging purposes.

```ruby
http = client.http
```

#### SMS Example

```ruby
client.messages.sms.create(
  :from => '+16505551212',
  :to => '+14155551212',
  :text => 'Hi there!'
)
```

#### Fax Example

Fax files:

```ruby
client.messages.fax.create(
  :to => '+14155551212',
  :coverPageText => 'Hi there!',
  :files => ['/path/to/myfile.pdf']
)
```

Fax text:

```ruby
client.messages.fax.create(
  :to => '+14155551212',
  :coverPageText => 'Hi there!',
  :text => 'Hi there!'
)
```

#### Subscription Example

To make subscriptions with RingCentral, use the SDK object to create subscription Observer object and then add observers to it.

```ruby
# Create an observer object
class MyObserver
  def update(message)
    puts "Subscription Message Received"
    puts JSON.dump(message)
  end
end

# Create an observable subscription and add your observer
sub = client.create_subscription()
sub.add_observer(MyObserver.new())

# Subscribe to an arbitrary number of event filters
sub.subscribe(['/restapi/v1.0/account/~/extension/~/presence'])

# End the subscription
sub.destroy()
```

### Advanced Use Cases

1. [Subscribing to All Extensions](http://ringcentral-sdk-ruby.readthedocs.org/en/latest/usage/notifications/Subscriptions-All-Extensions/)
1. [Managing Call Queue Member Status](http://ringcentral-sdk-ruby.readthedocs.org/en/latest/usage/callqueues/Member-Status/)

## Supported Ruby Versions

This library supports and is [tested against](https://travis-ci.org/grokify/ringcentral-sdk-ruby) the following Ruby implementations:

1. Ruby 2.3.0
2. Ruby 2.2.0
3. Ruby 2.1.0
4. Ruby 2.0.0
5. Ruby 1.9.3
6. [JRuby](http://jruby.org/)
7. [Rubinius](http://rubinius.com/)

Note: Ruby 1.8.7 works except for subscription support which relies on the `pubnub` gem. If there is a need for 1.8.7 support, consider creating a GitHub issue so we can evalute creating a separate library for subscription handling.

## Releases

Releases with release notes are availabe on [GitHub releases](https://github.com/grokify/ringcentral-sdk-ruby/releases). Release notes include a high level description of the release as well as lists of non-breaking and breaking changes.

### Versioning

This project is currently in development and the API can change. During initial development (Version 0.x.x), minor version changes will indicate either substantial feature inclusion or breaking changes.

Once the project is version 1.0.0 or above, it will use [semantic versioning](http://semver.org/). At this time, breaking changes will be indicated by a change in major version.

### Change Log

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

RingCentral SDK &copy; 2015-2016 by John Wang

 [gem-version-svg]: https://badge.fury.io/rb/ringcentral_sdk.svg
 [gem-version-link]: http://badge.fury.io/rb/ringcentral_sdk
 [downloads-svg]: http://ruby-gem-downloads-badge.herokuapp.com/ringcentral_sdk
 [downloads-link]: https://rubygems.org/gems/ringcentral_sdk
 [build-status-svg]: https://api.travis-ci.org/grokify/ringcentral-sdk-ruby.svg?branch=master
 [build-status-link]: https://travis-ci.org/grokify/ringcentral-sdk-ruby
 [coverage-status-svg]: https://coveralls.io/repos/grokify/ringcentral-sdk-ruby/badge.svg?branch=master
 [coverage-status-link]: https://coveralls.io/r/grokify/ringcentral-sdk-ruby?branch=master
 [dependency-status-svg]: https://gemnasium.com/grokify/ringcentral-sdk-ruby.svg
 [dependency-status-link]: https://gemnasium.com/grokify/ringcentral-sdk-ruby
 [codeclimate-status-svg]: https://codeclimate.com/github/grokify/ringcentral-sdk-ruby/badges/gpa.svg
 [codeclimate-status-link]: https://codeclimate.com/github/grokify/ringcentral-sdk-ruby
 [scrutinizer-status-svg]: https://scrutinizer-ci.com/g/grokify/ringcentral-sdk-ruby/badges/quality-score.png?b=master
 [scrutinizer-status-link]: https://scrutinizer-ci.com/g/grokify/ringcentral-sdk-ruby/?branch=master
 [docs-readthedocs-svg]: https://img.shields.io/badge/docs-readthedocs-blue.svg
 [docs-readthedocs-link]: http://ringcentral-sdk-ruby.readthedocs.org/
 [docs-rubydoc-svg]: https://img.shields.io/badge/docs-rubydoc-blue.svg
 [docs-rubydoc-link]: http://www.rubydoc.info/gems/ringcentral_sdk/
 [license-svg]: https://img.shields.io/badge/license-MIT-blue.svg
 [license-link]: https://github.com/grokify/ringcentral-sdk-ruby/blob/master/LICENSE.txt
