# frozen_string_literal: true

describe QA::Runtime::Feature do
  let(:api_client) { double('QA::Runtime::API::Client') }
  let(:request) { Struct.new(:url).new('http://api') }
  let(:response_post) { Struct.new(:code).new(201) }
  let(:response_get) { Struct.new(:code, :body).new(200, '[{ "name": "a-flag", "state": "on" }]') }

  before do
    allow(described_class).to receive(:api_client).and_return(api_client)
  end

  shared_examples 'a feature flag' do
    it 'enables a feature flag for a scope' do
      expect(QA::Runtime::API::Request).to receive(:new)
        .with(api_client, "/features/a-flag").and_return(request)
      expect(described_class).to receive(:post)
        .with(request.url, { value: true, scope => actor_name }).and_return(response_post)
      expect(QA::Runtime::API::Request).to receive(:new)
        .with(api_client, "/features").and_return(request)

      described_class.enable_and_verify('a-flag', scope => actor)
    end

    it 'disables a feature flag for a scope' do
      allow(described_class).to receive(:get)
        .and_return(Struct.new(:code, :body).new(200, '[{ "name": "a-flag", "state": "off" }]'))

      expect(QA::Runtime::API::Request).to receive(:new)
        .with(api_client, "/features/a-flag").and_return(request)
      expect(described_class).to receive(:post)
        .with(request.url, { value: false, scope => actor_name }).and_return(response_post)
      expect(QA::Runtime::API::Request).to receive(:new)
        .with(api_client, "/features").and_return(request)

      described_class.disable_and_verify('a-flag', scope => actor )
    end
  end

  describe '.enable_and_verify' do
    before do
      allow(described_class).to receive(:get).and_return(response_get)
    end

    it 'enables a feature flag' do
      expect(QA::Runtime::API::Request).to receive(:new)
        .with(api_client, "/features/a-flag").and_return(request)
      expect(described_class).to receive(:post)
        .with(request.url, { value: true }).and_return(response_post)
      expect(QA::Runtime::API::Request).to receive(:new)
        .with(api_client, "/features").and_return(request)

      described_class.enable_and_verify('a-flag')
    end

    context 'when a project scope is provided' do
      it_behaves_like 'a feature flag' do
        let(:scope) { :project }
        let(:actor_name) { 'group-name/project-name' }
        let(:actor) { Struct.new(:full_path).new(actor_name) }
      end
    end

    context 'when a group scope is provided' do
      it_behaves_like 'a feature flag' do
        let(:scope) { :group }
        let(:actor_name) { 'group-name' }
        let(:actor) { Struct.new(:full_path).new(actor_name) }
      end
    end

    context 'when a user scope is provided' do
      it_behaves_like 'a feature flag' do
        let(:scope) { :user }
        let(:actor_name) { 'user-name' }
        let(:actor) { Struct.new(:username).new(actor_name) }
      end
    end
  end

  describe '.disable_and_verify' do
    it 'disables a feature flag' do
      allow(described_class).to receive(:get)
        .and_return(Struct.new(:code, :body).new(200, '[{ "name": "a-flag", "state": "off" }]'))

      expect(QA::Runtime::API::Request).to receive(:new)
        .with(api_client, "/features/a-flag").and_return(request)
      expect(described_class).to receive(:post)
        .with(request.url, { value: false }).and_return(response_post)
      expect(QA::Runtime::API::Request).to receive(:new)
        .with(api_client, "/features").and_return(request)

      described_class.disable_and_verify('a-flag')
    end
  end

  describe '.enabled?' do
    it 'returns a feature flag state' do
      expect(QA::Runtime::API::Request)
        .to receive(:new)
        .with(api_client, "/features")
        .and_return(request)
      expect(described_class)
        .to receive(:get)
        .and_return(response_get)

      expect(described_class.enabled?('a-flag')).to be_truthy
    end
  end
end
