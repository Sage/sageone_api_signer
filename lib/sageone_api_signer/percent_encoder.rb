class SageoneApiSigner
  # Provides a method to percent-encode a string
  module PercentEncoder

    # Percent-encode the given string
    def percent_encode(str)
      URI.escape(str.to_s, /[^0-9A-Za-z\-._~]/)
    end
  end
end
