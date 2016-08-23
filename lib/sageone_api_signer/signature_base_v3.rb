require "rack/utils"

class SageoneApiSigner
  # Class to generate the signature base for generating the actual signature.
  # The string value (#to_s) of this class will be used as the `key` value in `OpenSSL::HMAC.digest(digest, key, data)`
  # This class generates a signature base valid for v3 of the Sage One API.
  class SignatureBaseV3 < SignatureBaseV2

    private

    def parameter_string
      query_params.merge("body" => encoded_body).to_query
    end

    def query_params
      ::Rack::Utils.parse_nested_query(uri.query)
    end

    def encoded_body
      Base64.strict_encode64(request_body)
    end

    def request_body
      @request_body ||= body.to_s
    end

    def signature_base_array
      super << percent_encode(business_guid)
    end
  end
end
