require "spec_helper"

RSpec.describe SageoneApiSigner::SignatureBaseV3 do

  let(:request_method) { "POST" }
  let(:url) { "https://api.sage.com/gb/sageone/accounts/v3/contacts?config_setting=foo" }
  let(:uri) { URI(url) }
  let(:body_params) { {"contact[contact_type_id]" => "1", "contact[name]" => "My Customer"} }
  let(:nonce) { "d6657d14f6d3d9de453ff4b0dc686c6d" }
  let(:object) { described_class.new(request_method, uri, body_params, nonce) }

  subject { object }

  it { is_expected.to be_a SageoneApiSigner::SignatureBaseV2 }

end
