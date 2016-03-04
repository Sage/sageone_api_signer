require "sageone_api_signer/version"
require "sageone_api_signer/percent_encoder"
require "sageone_api_signer/signature_base_v2"
require "sageone_api_signer/signature_base_v3"
require "active_support/core_ext/object/to_query"
require "base64"

# Sign a Sage One API request call following the steps detailed here:
# https://developers.sageone.com/docs#signing_your_requests
class SageoneApiSigner

  include SageoneApiSigner::PercentEncoder

  attr_accessor :url, :body, :body_params, :signing_secret, :access_token
  attr_writer :request_method, :nonce

  def initialize(params = {})
    params.each do |attr, val|
      self.public_send("#{attr}=", val)
    end
  end

  # The request headers
  def request_headers(user_agent)
    {
      'Authorization' => "Bearer #{access_token}",
      'X-Nonce' => nonce,
      'X-Signature' => signature,
      'Accept' => '*/*',
      'Content-Type' => 'application/x-www-form-urlencoded',
      'User-Agent' => user_agent
    }
  end

  # The secure random generated string
  def nonce
    @nonce ||= SecureRandom.hex
  end

  # generate a Base64 encoded signature
  def signature
    @signature ||= Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), signing_key, signature_base.to_s))
  end

  # Returns GET, POST, PUT, etc.
  def request_method
    @request_method.to_s.upcase
  end

  private

  def uri
    @uri ||= URI(url)
  end

  def signature_base
    @signature_base ||= signature_base_class.new(request_method, uri, body, body_params, nonce)
  end

  def signature_base_class
    if uri.path =~ %r{\A/(\w+/)+v[12]/}     # path must start with "/foo/bar/baz/v2/" (example)
      SignatureBaseV2
    elsif uri.path =~ %r{\A/(\w+/)+v[3]/}   # path must start with "/foo/bar/baz/v3/" (example)
      SignatureBaseV3
    end
  end

  def signing_key
    @signing_key ||= [
      percent_encode(signing_secret),
      percent_encode(access_token)
    ].join('&')
  end
end
