RSpec.describe SageoneApiSigner do
  it { expect(subject).to respond_to :request_method }
  it { expect(subject).to respond_to :url }
  it { expect(subject).to respond_to :body_params }
  it { expect(subject).to respond_to :nonce }
  it { expect(subject).to respond_to :signing_secret }
  it { expect(subject).to respond_to :access_token }
  it { expect(subject).to respond_to :business_guid }

  it 'should set everything on initialize' do
    obj = described_class.new(
      request_method: 'method',
      url: 'url',
      body_params: 'body',
      nonce: 'nonce',
      signing_secret: 'secret',
      access_token: 'token',
      business_guid: 'bad0ff1ce'
    )

    expect(obj.request_method).to eql 'METHOD'
    expect(obj.url).to            eql 'url'
    expect(obj.body_params).to    eql 'body'
    expect(obj.nonce).to          eql 'nonce'
    expect(obj.signing_secret).to eql 'secret'
    expect(obj.access_token).to   eql 'token'
    expect(obj.business_guid).to  eql 'bad0ff1ce'
  end

  let(:url) { 'https://api.sageone.com/accounts/v1/contacts?config_setting=foo' }

  subject do
    described_class.new(
      request_method: 'post',
      url: url,
      nonce: 'd6657d14f6d3d9de453ff4b0dc686c6d',
      body_params: {
        'contact[contact_type_id]' => 1,
        'contact[name]' => 'My Customer',
      }
    )
  end

  describe '#request_headers' do
    it 'should help write the request headers' do
      expect(subject.request_headers('foo')).to eql({
        'Authorization' => "Bearer #{subject.access_token}",
        'X-Nonce' => subject.nonce,
        'X-Signature' => subject.signature,
        'Accept' => '*/*',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'User-Agent' => 'foo'
      })
    end
  end

  context 'when a business GUID was passed' do
    before do
      subject.business_guid = 'bad0ff1ce'
    end

    it 'sets the X-Site header' do
      expect(subject.request_headers('foo')['X-Site']).to eql 'bad0ff1ce'
    end
  end

  describe '#nonce' do
    it 'should build a random one by default' do
      expect(SecureRandom).to receive(:hex).once.and_return('random nonce')
      obj = described_class.new

      expect(obj.nonce).to eql 'random nonce'
    end
  end

  describe '#signature' do
    it 'should hash this way' do
      expected = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'),
          subject.send(:signing_key), subject.send(:signature_base).to_s))
      expect(subject.signature).to eql expected
    end
  end

  describe '#request_method' do
    it 'BUG nil the second time we call it!!!' do
      subject.request_method = 'get'
      expect(subject.request_method).to eql 'GET'
    end
  end

  describe '#uri' do
    it 'should be an URI with the URL' do
      subject.url = 'http://www.google.com.br'
      expect(subject.send(:uri)).to eql URI('http://www.google.com.br')
    end
  end

  describe '#signature_base' do
    context "when the call goes to API version 1 or 2" do
      it 'returns a SignatureBase instance' do
        expect(subject.send(:signature_base)).to be_a SageoneApiSigner::SignatureBaseV2
      end

      it 'returns the correct signature when converted to string' do
        expected = 'POST&https%3A%2F%2Fapi.sageone.com%2Faccounts%2Fv1%2Fcontacts&config_setting%3Dfoo%26' \
                   'contact%255Bcontact_type_id%255D%3D1%26contact%255Bname%255D%3DMy%2520Customer&d6657d14f6d3d9de453ff4b0dc686c6d'
        expect(subject.send(:signature_base).to_s).to eql expected
      end
    end

    context "when the call goes to API version 3" do
      let(:url) { "https://api.leiferikson.sage.com/gb/sageone/accounts/v3/contacts?config_type_id=vendor" }

      before do
        subject.business_guid = 'bad0ff1ce'
      end

      it 'returns a SignatureBase instance' do
        expect(subject.send(:signature_base)).to be_a SageoneApiSigner::SignatureBaseV3
      end

      it 'returns the correct signature when converted to string' do
        expected = 'POST&https%3A%2F%2Fapi.leiferikson.sage.com%2Fgb%2Fsageone%2Faccounts%2Fv3%2Fcontacts&' \
                   'body%3D%26config_type_id%3Dvendor&d6657d14f6d3d9de453ff4b0dc686c6d&bad0ff1ce'
        expect(subject.send(:signature_base).to_s).to eql expected
      end
    end

    context "when the call goes to an unknown API version" do
      let(:url) { "https://sage.api/gb/sageone/accounts/v99/contacts" }

      it 'raises an error' do
        expect { subject.send(:signature_base) }.to raise_error "Cannot determine API version from https://sage.api/gb/sageone/accounts/v99/contacts"
      end
    end
  end

  describe '#signing_key' do
    it 'should be the secret & token percent encoded' do
      subject.signing_secret = '297850d556xxxxxxxxxxxxxxxxxxxxe722db1d2a'
      subject.access_token = 'cULSIjxxxxxIhbgbjX0R6MkKO'
      expect(subject.send(:signing_key)).to eql '297850d556xxxxxxxxxxxxxxxxxxxxe722db1d2a&cULSIjxxxxxIhbgbjX0R6MkKO'
    end
  end

  describe 'verifies form content_type' do
    it 'should return application/x-www-form-urlencoded when form data passed' do
      expect(subject.request_headers('foo')["Content-Type"]).to eql "application/x-www-form-urlencoded"
    end
  end

  describe 'verifies json content-type' do
    after do
      JSON.parse subject.body_params
    end

    let(:v3_url) { "https://api.columbus.sage.com/uki/sageone/accounts/v3/contacts" }

    it 'should return application/json when json data passed' do
      json  = "{\"contact\":{\"name\": \"Wayne\",\"contact_type_ids\":[\"CUSTOMER\"]}}"
      subject.body_params = json
      subject.url = v3_url

      subject do
        described_class.new(
          request_method: 'post',
          url: v3_url,
          nonce: 'd6657d14f6d3d9de453ff4b0dc686c6d',
          body_params: json
        )
      end
      expect(subject.request_headers('foo')["Content-Type"]).to eql "application/json"
    end
  end
end
