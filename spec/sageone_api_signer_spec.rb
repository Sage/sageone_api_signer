RSpec.describe SageoneApiSigner do
  it { expect(subject).to respond_to :request_method }
  it { expect(subject).to respond_to :url }
  it { expect(subject).to respond_to :body_params }
  it { expect(subject).to respond_to :nonce }
  it { expect(subject).to respond_to :signing_secret }
  it { expect(subject).to respond_to :access_token }

  it 'should set everything on initialize' do
    obj = described_class.new(
      request_method: 'method',
      url: 'url',
      body_params: 'body',
      nonce: 'nonce',
      signing_secret: 'secret',
      access_token: 'token',
    )

    expect(obj.request_method).to eql 'METHOD'
    expect(obj.url).to            eql 'url'
    expect(obj.body_params).to    eql 'body'
    expect(obj.nonce).to          eql 'nonce'
    expect(obj.signing_secret).to  eql 'secret'
    expect(obj.access_token).to   eql 'token'
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

  describe '#nonce' do
    it 'should build a rondom one by default' do
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
      let(:url) { "https://api.sage.com/gb/sageone/accounts/v3/contacts?config_setting=foo" }

      it 'returns a SignatureBase instance' do
        expect(subject.send(:signature_base)).to be_a SageoneApiSigner::SignatureBaseV3
      end

      it 'returns the correct signature when converted to string' do
        expected = 'POST&https%3A%2F%2Fapi.sage.com%2Fgb%2Fsageone%2Faccounts%2Fv3%2Fcontacts&' \
                   'body%3DeyJjb250YWN0W2NvbnRhY3RfdHlwZV9pZF0iOjEsImNvbnRhY3RbbmFtZV0iOiJNeSBDdXN0b21lciJ9%26' \
                   'config_setting%3Dfoo&d6657d14f6d3d9de453ff4b0dc686c6d'
        expect(subject.send(:signature_base).to_s).to eql expected
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
end
