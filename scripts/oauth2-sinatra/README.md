RingCentral 3-Legged OAuth Demo in Ruby
=======================================

## Overview

This is a quick 3-legged OAuth demo that runs using Ruby and Sinatra with the [RingCentral Ruby SDK](https://github.com/grokify/ringcentral-sdk-ruby) v1.2.1.

## Installation

### Via Bundler

```bash
$ git clone https://github.com/grokify/ringcentral-demos-oauth
$ cd ringcentral-oauth-demos/ruby-sinatra
$ bundle
```

### Via Ruby Gems

```bash
$ gem install ringcentral_sdk
$ gem install sinatra
$ git clone https://github.com/grokify/ringcentral-demos-oauth
```

## Configuration

Edit the `.env` file to add your application key and application secret.

```bash
$ cd ringcentral-demos-oauth/ruby-sinatra
$ cp config-sample.env.txt .env
$ vi .env
```

In the [Developer Portal](http://developer.ringcentral.com/), ensure the redirect URI in your config file has been entered in your app configuration. By default, the URL is set to the following for this demo:

```
http://localhost:8080/callback
```

## Usage

Open the web page:

```bash
$ ruby app.rb
```

Go to the URL:

```
http://localhost:8080
````

Then click the <input type="button" value="Login with RingCentral"> button to authorize the demo app and view the access token.
