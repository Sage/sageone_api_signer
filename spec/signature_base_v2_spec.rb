require "spec_helper"

RSpec.describe SageoneApiSigner::SignatureBaseV2 do

  let(:request_method) { "POST" }
  let(:url) { "https://api.sageone.com/accounts/v1/contacts?config_setting=foo" }
  let(:uri) { URI(url) }
  let(:body) { "" }
  let(:body_params) { {"contact[contact_type_id]" => "1", "contact[name]" => "My Customer"} }
  let(:nonce) { "d6657d14f6d3d9de453ff4b0dc686c6d" }
  let(:business_guid) { "bad0ff1ce" }

  let(:object) { described_class.new(request_method, uri, body, body_params, nonce, business_guid) }

  subject { object }

  describe "#to_s" do
    let(:expected) { 'POST&https%3A%2F%2Fapi.sageone.com%2Faccounts%2Fv1%2Fcontacts&config_setting%3Dfoo%26' \
      'contact%255Bcontact_type_id%255D%3D1%26contact%255Bname%255D%3DMy%2520Customer&d6657d14f6d3d9de453ff4b0dc686c6d' }

    it "should follow the website example" do
      expect(subject.to_s).to eql expected
    end
  end

  describe '#parameter_string' do

    subject { object.send(:parameter_string) }

    it 'should match the website example' do
      expect(subject).to eql 'config_setting=foo&contact%5Bcontact_type_id%5D=1&contact%5Bname%5D=My%20Customer'
    end

    context "when params are passed unsorted" do
      let(:url) { "https://api.sageone.com/accounts/v1/contacts?zee=4&bee=2" }
      let(:body_params) { {"aaa" => "1", "dee" => "3"} }

      it 'should sort the params' do
        expect(subject).to eql 'aaa=1&bee=2&dee=3&zee=4'
      end
    end

    context "when + chars are passed" do
      let(:url) { "https://api.sageone.com/accounts/v1/contacts?in_the_url=i+cant+have+pluses" }
      let(:body_params) { {"in_the_body_param" => "cant have pluses here too"} }

      it 'cant have +, should have %20' do
        expect(subject).to eql 'in_the_body_param=cant%20have%20pluses%20here%20too&in_the_url=i%20cant%20have%20pluses'
      end
    end
  end

  describe '#base_url' do
    let(:url) { "https://api.sageone.com/accounts/v1/contacts?config_setting=foo" }

    subject { object.send(:base_url) }

    it "uses the default port" do
      expect(subject).to eql 'https://api.sageone.com/accounts/v1/contacts'
    end

    context "when the URL has a specific port" do
      let(:url) { "https://api.sageone.com:123/accounts/v1/contacts?config_setting=foo" }

      it "contains the port" do
        expect(subject).to eql 'https://api.sageone.com:123/accounts/v1/contacts'
      end
    end
  end

  describe '#url_params' do
    let(:url) { "https://api.sageone.com/accounts/v1/contacts?response_type=code&client_id=4b64axxxxxxxxxx00710&scope=full_access" }

    it 'should give me a has from the url query' do
      expect(subject.send(:url_params)).to eql({
        'response_type' => 'code',
        'client_id' => '4b64axxxxxxxxxx00710',
        'scope' => 'full_access'
      })
    end
  end
end
