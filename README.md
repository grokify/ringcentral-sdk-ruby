RingCentral SDK for Ruby
========================

[![Gem Version][gem-version-svg]][gem-version-url]
[![Build Status][build-status-svg]][build-status-url]
[![Coverage Status][coverage-status-svg]][coverage-status-url]
[![Code Climate][codeclimate-status-svg]][codeclimate-status-url]
[![Scrutinizer Code Quality][scrutinizer-status-svg]][scrutinizer-status-url]
[![Docs][docs-readthedocs-svg]][docs-readthedocs-url]
[![Docs][docs-rubydoc-svg]][docs-rubydoc-url]
[![License][license-svg]][license-url]

[![Stack Overflow][stackoverflow-svg]][stackoverflow-url]
[![Chat][chat-svg]][chat-url]

## Table of contents

1. [Overview](#overview)
2. [Documentation](#documentation)
3. [Installation](#installation)
4. [Usage](#usage)
  1. [Synopsis](#synopsis)
  1. [API Requests](#api-requests)
    1. [Generic HTTP Requests](#generic-http-requests)
    2. [SMS and MMS Examples](#sms-and-mms-examples)
    3. [Fax Examples](#fax-examples)
  1. [Advanced Use Cases](#advanced-use-cases)
5. [Supported Ruby Versions](#supported-ruby-versions)
6. [Releases](#releases)
  1. [Versioning](#versioning)
  1. [Change Log](#change-log)
8. [Links](#links)
9. [Contributions](#contributions)
10. [License](#license)

## Overview

A Ruby SDK for the [RingCentral REST API](https://developers.ringcentral.com).

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

### Synopsis

```ruby
require 'ringcentral_sdk'

client = RingCentralSdk::REST::Client.new do |config|
  # App info (mandatory)
  config.client_id = 'myAppClientID'
  config.client_secret = 'myAppClientSecret'
  config.server_url = RingCentralSdk::RC_SERVER_SANDBOX

  # JWT Bearer Grant (optional)
  config.jwt = 'myJwt'

  # Set a custom logger (optional)
  config.logger = Logger.new(STDOUT)

  # Enable HTTP retries for 429, 503, and 504 errors
  # Set custom codes and retry after using retry_options
  config.retry = true
end

# Send SMS
res = client.messages.sms.create(
  from: '+16505551212',
  to: '+14155551212',
  text: 'Hi there!'
)
```

More information on the authorization code flow:

1. [Full documentation](http://ringcentral-sdk-ruby.readthedocs.org/en/latest/usage/authorization/Authorization/#authorization-code-grant)
2. [Sinatra example](scripts/oauth2-sinatra)

### API Requests

API requests can be made via the included `Faraday` client or `RingCentralSdk::Helpers::Request` subclasses. These are described below.

#### Generic HTTP Requests

To make generic API requests, use included `Faraday` client which can be accessed via `client.http`. The client automatically adds the correct access token to the HTTP request and handles OAuth token refresh using the `OAuth` gem.

This is useful to access many API endpoints which do not have custom wrappers and for debugging purposes.

```ruby
http = client.http
```

#### SMS and MMS Examples

SMS:

```ruby
client.messages.sms.create(
  from: '+16505551212',
  to: '+14155551212',
  text: 'Hi there!'
)
```

MMS with media file:

```ruby
client.messages.sms.create(
  from: '+16505551212',
  to: '+14155551212',
  text: 'Hi there!',
  media: '/filepath/to/file.ext'
)
```

#### Fax Examples

Fax files:

```ruby
client.messages.fax.create(
  to: '+14155551212',
  coverPageText: 'Hi there!',
  files: ['/path/to/myfile.pdf']
)
```

Fax text:

```ruby
client.messages.fax.create(
  to: '+14155551212',
  coverPageText: 'Hi there!',
  text: 'Hi there!'
)
```

#### Subscription Example

To make subscriptions with RingCentral, use the SDK object to create subscription Observer object and then add observers to it.

```ruby
# Create an observer object
class MyObserver
  def update(message)
    puts 'Subscription Message Received'
    puts JSON.dump(message)
  end
end

# Create an observable subscription and add your observer
sub = client.create_subscription
sub.add_observer MyObserver.new

# Subscribe to an arbitrary number of event filters
sub.subscribe ['/restapi/v1.0/account/~/extension/~/presence']

# End the subscription
sub.destroy
```

### Examples

See examples in the [`scripts`](scripts) folder.

A simple read only script is `account-extensions.rb` which can be used to validate your app configuration.

### Advanced Use Cases

1. [Subscribing to All Extensions](http://ringcentral-sdk-ruby.readthedocs.org/en/latest/usage/notifications/Subscriptions-All-Extensions/)
1. [Managing Call Queue Member Status](http://ringcentral-sdk-ruby.readthedocs.org/en/latest/usage/callqueues/Member-Status/)

## Supported Ruby Versions

This library is tested against [this list of Ruby implementations](https://travis-ci.org/grokify/ringcentral-sdk-ruby).

## Releases

Releases with release notes are availabe on [GitHub releases](https://github.com/grokify/ringcentral-sdk-ruby/releases). Release notes include a high level description of the release as well as lists of non-breaking and breaking changes.

### Versioning

* Versions 1.0.0 and above follow [semantic versioning](http://semver.org/). Breaking changes will be indicated by a change in major version.
* Versions below 1.0.0 are in active development. During initial development (Version 0.x.x), minor version changes will indicate either substantial feature inclusion or breaking changes.

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

## Contributing

1. Fork it ( http://github.com/grokify/ringcentral-sdk-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Development

To build local development copy of the gem use:

```
% gem build ringcentral_sdk.gemspec
```

This will produce a file like: `ringcentral_sdk-3.1.0.gem` which you can install with:

```
% gem install ringcentral_sdk-3.1.0.gem
```

## License

RingCentral SDK is available under the MIT license. See [LICENSE](LICENSE) for details.

RingCentral SDK &copy; 2015-2024 by John Wang

 [gem-version-svg]: https://badge.fury.io/rb/ringcentral_sdk.svg
 [gem-version-url]: http://badge.fury.io/rb/ringcentral_sdk
 [downloads-svg]: http://ruby-gem-downloads-badge.herokuapp.com/ringcentral_sdk
 [downloads-url]: https://rubygems.org/gems/ringcentral_sdk
 [build-status-svg]: https://github.com/grokify/ringcentral-sdk-ruby/workflows/test/badge.svg?branch=master
 [build-status-url]: https://github.com/grokify/ringcentral-sdk-ruby/actions/workflows/test.yaml
 [coverage-status-svg]: https://coveralls.io/repos/grokify/ringcentral-sdk-ruby/badge.svg?branch=master
 [coverage-status-url]: https://coveralls.io/r/grokify/ringcentral-sdk-ruby?branch=master
 [dependency-status-svg]: https://gemnasium.com/grokify/ringcentral-sdk-ruby.svg
 [dependency-status-url]: https://gemnasium.com/grokify/ringcentral-sdk-ruby
 [codacy-svg]: https://api.codacy.com/project/badge/Grade/4792fe45b56b4841a7e6099c316ac0f8
 [codacy-url]: https://www.codacy.com/app/grokify/ringcentral-sdk-ruby
 [codeclimate-status-svg]: https://codeclimate.com/github/grokify/ringcentral-sdk-ruby/badges/gpa.svg
 [codeclimate-status-url]: https://codeclimate.com/github/grokify/ringcentral-sdk-ruby
 [scrutinizer-status-svg]: https://scrutinizer-ci.com/g/grokify/ringcentral-sdk-ruby/badges/quality-score.png?b=master
 [scrutinizer-status-url]: https://scrutinizer-ci.com/g/grokify/ringcentral-sdk-ruby/?branch=master
 [story-status-svg]: https://badge.waffle.io/grokify/ringcentral-sdk-ruby.svg?label=ready&title=Ready
 [story-status-url]: https://waffle.io/grokify/ringcentral-sdk-ruby
 [docs-readthedocs-svg]: https://img.shields.io/badge/docs-readthedocs-blue.svg
 [docs-readthedocs-url]: http://ringcentral-sdk-ruby.readthedocs.org/
 [docs-rubydoc-svg]: https://img.shields.io/badge/docs-rubydoc-blue.svg
 [docs-rubydoc-url]: http://www.rubydoc.info/gems/ringcentral_sdk/
 [license-svg]: https://img.shields.io/badge/license-MIT-blue.svg
 [license-url]: https://github.com/grokify/ringcentral-sdk-ruby/blob/master/LICENSE
 [chat-svg]: https://img.shields.io/badge/chat-on%20glip-orange.svg
 [chat-url]: https://glipped.herokuapp.com/
 [stackoverflow-svg]: https://img.shields.io/badge/Stack%20Overflow-ringcentral-orange.svg
 [stackoverflow-url]: https://stackoverflow.com/questions/tagged/ringcentral
