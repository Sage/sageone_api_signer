require "sageone_api_signer/version"
require "sageone_api_signer/percent_encoder"
require "sageone_api_signer/signature_base"
require "active_support"
require "active_support/core_ext"
require "base64"

# Sign a Sage One API request call following the steps detailed here:
# https://developers.sageone.com/docs#signing_your_requests
class SageoneApiSigner

  include SageoneApiSigner::PercentEncoder

  attr_accessor :request_method, :url, :body_params, :nonce, :signing_secret, :access_token

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
    @signature_base ||= SignatureBase.new(request_method, uri, body_params, nonce)
  end

  def signing_key
    @signing_key ||= [
      percent_encode(signing_secret),
      percent_encode(access_token)
    ].join('&')
  end
end
