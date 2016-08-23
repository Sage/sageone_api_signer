class SageoneApiSigner
  # Class to generate the signature base for generating the actual signature.
  # The string value (#to_s) of this class will be used as the `key` value in `OpenSSL::HMAC.digest(digest, key, data)`
  # This class generates a signature base valid for v1 and v2 of the Sage One API.
  class SignatureBaseV2

    include SageoneApiSigner::PercentEncoder

    attr_reader :request_method, :uri, :body, :body_params, :nonce, :business_guid

    def initialize(request_method, uri, body, body_params, nonce, business_guid)
      @request_method = request_method
      @uri = uri
      @body = body
      @body_params = body_params
      @nonce = nonce
      @business_guid = business_guid
    end

    # Returns the signature base, that will be used for generating the actual signature
    def to_s
      @signature_base_string ||= signature_base_array.join('&')
    end

    private

    def parameter_string
      @parameter_string ||= Hash[url_params.merge(body_params).sort].to_query.gsub('+', '%20')
    end

    # Return the base URL without query string and fragment
    def base_url
      @base_url ||= [
        uri.scheme,
        '://',
        uri.host,
        uri_port_string,
        uri.path
      ].join
    end

    def url_params
      @url_params ||= Hash[URI::decode_www_form(uri.query || '')]
    end

    def uri_port_string
      uri.port == uri.default_port ? "" : ":#{uri.port}"
    end

    def signature_base_array
      [
          request_method,
          percent_encode(base_url),
          percent_encode(parameter_string),
          percent_encode(nonce)
      ]
    end
  end
end
