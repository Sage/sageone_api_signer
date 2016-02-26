class SageoneApiSigner
  # Provides a method to percent-encode a string
  module PercentEncoder

    # Percent-encode the given string
    def percent_encode(str)
      ERB::Util.url_encode(str)
    end
  end
end
