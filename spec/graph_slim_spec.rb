# frozen_string_literal: true

describe GraphSlim do
  describe 'VERSION' do
    it 'has a version number' do
      expect(GraphSlim::VERSION).not_to be_nil
    end
  end

  describe '#get' do
    let(:graph) do
      described_class.new('tenant_id', 'client_id', 'client_secret')
    end

    before do
      klass = MicrosoftKiotaAuthenticationOAuth::ClientCredentialContext
      allow_any_instance_of(klass).to receive(:get_token).and_return(double('AccessToken', token: 'fake_token',
                                                                                           expired?: false))
      allow_any_instance_of(klass).to receive(:initialize_oauth_provider)
      allow_any_instance_of(klass).to receive(:initialize_scopes)

      response = double('Response', status: 200, body: {'value' => [{ 'id' => '1', 'name' => 'Test User' }] })
      allow(graph.send(:connection)).to receive(:get).and_return(response)
    end

    context 'the request is successful' do
      it 'returns a list of users' do
        response = graph.get('/users')
        expect(response).to be_an(Array)
        expect(response.first).to be_a(GraphSlim::Response)
        expect(response.first.id).not_to be_nil
      end
    end

    context 'paging through results' do
      before do
        first_response = double('FirstResponse', status: 200, body: {
          'value' => [{ 'id' => '1', 'name' => 'Test User' }],
          '@odata.nextLink' => 'https://graph.microsoft.com/v1.0/users?page=2'
        })
        second_response = double('SecondResponse', status: 200, body: {
          'value' => [{ 'id' => '2', 'name' => 'Another User' }],
          '@odata.nextLink' => nil
        })
        allow(graph.send(:connection)).to receive(:get).and_return(first_response, second_response)
      end
      it 'fetches all pages of results' do
        response = graph.get('/users')
        expect(response.size).to eq(2)
        expect(response.map(&:id)).to contain_exactly('1', '2')
      end
    end

    context 'with invalid API version' do
      it 'raises an ArgumentError' do
        expect do
          graph.get('/users', version: 'invalid_version')
        end.to raise_error(ArgumentError, /Invalid version: invalid_version/)
      end
    end

    context 'the request fails' do
      before do
        response = double('Response', status: 404, body: { 'error' => { 'message' => 'Not Found' } })
        allow(graph.send(:connection)).to receive(:get).and_return(response)
      end

      it 'raises an error for invalid requests' do
        expect do
          graph.get('/invalid_endpoint')
        end.to raise_error(StandardError, /Not Found/)
      end
    end
  end
end
