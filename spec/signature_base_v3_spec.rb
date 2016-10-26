require "spec_helper"

RSpec.describe SageoneApiSigner::SignatureBaseV3 do

  let(:request_method) { "POST" }
  let(:url) { "https://api.sage.com/gb/sageone/accounts/v3/contacts?config_setting=foo" }
  let(:uri) { URI(url) }
  let(:body) { "" }
  let(:body_params) { {"contact[contact_type_id]" => "1", "contact[name]" => "My Customer"} }
  let(:nonce) { "d6657d14f6d3d9de453ff4b0dc686c6d" }
  let(:business_guid) { "bad0ff1ce" }
  let(:object) { described_class.new(request_method, uri, body, body_params, nonce, business_guid) }

  subject { object }

  it { is_expected.to be_a SageoneApiSigner::SignatureBaseV3 }

  describe "#to_s" do
    let(:expected) { 'POST&https%3A%2F%2Fapi.sage.com%2Fgb%2Fsageone%2Faccounts%2Fv3%2Fcontacts&' \
                     'body%3D%26config_setting%3Dfoo&d6657d14f6d3d9de453ff4b0dc686c6d&bad0ff1ce' }

    it "should follow the website example" do
      expect(subject.to_s).to eql expected
    end
  end

  describe '#parameter_string' do
    let(:expected) { 'body=&config_setting=foo' }

    it "should follow the website example" do
      expect(subject.send(:parameter_string)).to eql expected
    end

    context 'when parameter string includes a space' do
      let(:url) { "https://api.sage.com/gb/sageone/accounts/v3/contacts?config_setting=foo bar" }
      let(:expected) { 'body=&config_setting=foo%20bar' }
      it 'should percent encode spaces as %20' do
        expect(subject.send(:parameter_string)).to eql expected
      end
    end
  end

  describe "#query_params" do
    let(:query_array) { [["foo[blah]", "12"], ["foo[blub]", "23"], ["foo[bar][][baz]", "34"], ["foo[bar][][baa]", "45"]] }
    let(:url) { "http://api.com/v3/bars?" << URI::encode_www_form(query_array) }

    it "returns the nested query params as a hash" do
      expect(subject.send(:query_params)).to eql "foo" => {"blah" => "12", "blub" => "23",
                                                           "bar" => [{"baz" => "34", "baa" => "45"}]}
    end
  end

  describe "#encoded_body" do
    before do
      allow(subject).to receive(:request_body).and_return "foo=bar"
    end

    it "returns the base64 encoded body" do
      expect(subject.send(:encoded_body)).to eql "Zm9vPWJhcg=="
    end
  end

  describe "#request_body" do
    context "when the request has a body" do
      let(:body) { %|{"bar":"baz"}| }

      it "returns the body as JSON string" do
        expect(subject.send(:request_body)).to eql %|{"bar":"baz"}|
      end
    end

    context "when the request has no body" do
      before do
        allow(subject).to receive(:body_params).and_return ""
      end

      it "returns the body as JSON string" do
        expect(subject.send(:request_body)).to eql ""
      end
    end
  end
end
