# Sage One API Signer

[![Build Status](https://travis-ci.org/Sage/sageone_api_signer.svg?branch=master)](https://travis-ci.org/Sage/sageone_api_signer)

This gem handles the required signing of requests to the [Sage One](http://www.sageone.com) API.

The signing process is described in detail here: [https://developers.sageone.com/docs#signing_your_requests](https://developers.sageone.com/docs#signing_your_requests)

## Installation

Please note, we are currently only supporting Ruby 2.3.0.

Add the `sageone_api_signer` to your application's Gemfile:

```ruby
gem 'sageone_api_signer'
```

And then execute:

    $ bundle

Or install the gem yourself:

    $ gem install sageone_api_signer

## Usage

To create a `SageoneApiSigner` instance, you need to provide the following data:

```ruby
  @signer = SageoneApiSigner.new({
    request_method: 'post',
    url: 'https://api.sageone.com/test/accounts/v1/contacts?config_setting=foo',
    body_params: {
      'contact[contact_type_id]' => 1,
      'contact[name]' => 'My Customer'
    },
    signing_secret: 'YOUR_SIGNING_SECRET',
    access_token: 'YOUR_ACCESS_TOKEN',
  })
```

You can then generate the signature:

```ruby
  @signer.signature
  => "g1Cteq+JHjJzXYn7FpaLF42BymQ=\n"

```

or even the request headers:

```ruby
  @signer.request_headers("YOUR_APP_NAME")
  => {
  =>   'Authorization' => "Bearer 3a5cfe7c90a78276e247c73da7bf120fc5283693",
  =>   'X-Nonce' => "e673495125616bed53624a76db215a8a",
  =>   'X-Signature' => "g1Cteq+JHjJzXYn7FpaLF42BymQ=\n",
  =>   'Accept' => '*/*',
  =>   'Content-Type' => 'application/x-www-form-urlencoded',
  =>   'User-Agent' => "YOUR_APP_NAME"
  => }

```

You can see an example in this [integration test](spec/integration/check_signature_data_spec.rb).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/sageone_api_signer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
