RingCentral 3-Legged OAuth Demo in Ruby
=======================================

# Overview

This is a quick 3-legged OAuth demo that runs using Sinatra.

## Installation

### Via Bundler

```bash
$ git clone https://github.com/grokify/ringcentral-sdk-ruby
$ cd ringcentral-sdk-ruby/scripts/oauth2-sinatra
$ bundle
```

### Via Ruby Gems

```bash
$ gem install ringcentral_sdk
$ gem install sinatra
$ git clone https://github.com/grokify/ringcentral-sdk-ruby
```

## Configuration

Edit the `oauth2.rb` file to add your application key and application secret.

```bash
$ cd ringcentral-sdk-ruby/scripts/oauth2-sinatra
$ vi oauth2.rb
```

## Running the Demo

Open the web page:

```bash
$ ruby oauth2.rb
```

Then click the <input type="button" value="Login with RingCentral"> button to authorize the demo app and view the access token.