class SageoneApiSigner
  # Class to generate the signature base for generating the actual signature.
  # The string value (#to_s) of this class will be used as the `key` value in `OpenSSL::HMAC.digest(digest, key, data)`
  # This class generates a signature base valid for v3 of the Sage One API.
  class SignatureBaseV3 < SignatureBaseV2

  end
end
