describe Gitlab::QA::Runtime::Env do
  around do |example|
    # Reset any already defined env variables (e.g. on CI)
    ClimateControl.modify Hash[described_class::ENV_VARIABLES.keys.zip([nil])] do
      example.run
    end
  end

  describe '.run_id' do
    around do |example|
      described_class.instance_variable_set(:@run_id, nil)
      example.run
      described_class.instance_variable_set(:@run_id, nil)
    end

    it 'returns a unique run id' do
      now = Time.now
      allow(Time).to receive(:now).and_return(now)
      allow(SecureRandom).to receive(:hex).and_return('abc123')

      expect(described_class.run_id).to eq "gitlab-qa-run-#{now.strftime('%Y-%m-%d-%H-%M-%S')}-abc123"
      expect(described_class.run_id).to eq "gitlab-qa-run-#{now.strftime('%Y-%m-%d-%H-%M-%S')}-abc123"
    end
  end

  describe '.dev_access_token_variable' do
    context 'when there is an env variable set' do
      around do |example|
        ClimateControl.modify(GITLAB_QA_DEV_ACCESS_TOKEN: 'abc123') { example.run }
      end

      it 'returns directory defined in environment variable' do
        expect(described_class.dev_access_token_variable).to eq '$GITLAB_QA_DEV_ACCESS_TOKEN'
      end
    end

    context 'when there is no env variable set' do
      around do |example|
        ClimateControl.modify(GITLAB_QA_DEV_ACCESS_TOKEN: nil) { example.run }
      end

      it 'returns a default screenshots directory' do
        expect(described_class.dev_access_token_variable).to be_nil
      end
    end
  end

  describe '.host_artifacts_dir' do
    around do |example|
      described_class.instance_variable_set(:@host_artifacts_dir, nil)
      example.run
      described_class.instance_variable_set(:@host_artifacts_dir, nil)
    end

    context 'when there is an env variable set' do
      around do |example|
        ClimateControl.modify(QA_ARTIFACTS_DIR: '/tmp') { example.run }
      end

      it 'returns directory defined in environment variable' do
        expect(described_class.host_artifacts_dir).to eq "/tmp/#{described_class.run_id}"
      end
    end

    context 'when there is no env variable set' do
      around do |example|
        ClimateControl.modify(QA_ARTIFACTS_DIR: nil) { example.run }
      end

      it 'returns a default screenshots directory' do
        expect(described_class.host_artifacts_dir)
          .to eq "/tmp/gitlab-qa/#{described_class.run_id}"
      end
    end
  end

  describe '.variables' do
    around do |example|
      ClimateControl.modify(
        GITLAB_USERNAME: 'root',
        GITLAB_QA_ACCESS_TOKEN: nil,
        EE_LICENSE: nil) { example.run }
    end

    before do
      described_class.user_username = nil
      described_class.user_password = nil
      described_class.user_type = nil
      described_class.gitlab_url = nil
      described_class.ee_license = nil
    end

    it 'returns only these delegated variables that are set' do
      expect(described_class.variables).to eq({ 'GITLAB_USERNAME' => '$GITLAB_USERNAME' })
    end

    it 'prefers environment variables to defined values' do
      described_class.user_username = 'tanuki'

      expect(described_class.variables).to eq({ 'GITLAB_USERNAME' => '$GITLAB_USERNAME' })
    end

    it 'returns values that have been overriden' do
      described_class.user_password = 'tanuki'
      described_class.user_type = 'ldap'
      described_class.gitlab_url = 'http://localhost:9999'

      expect(described_class.variables).to eq({ 'GITLAB_USERNAME' => '$GITLAB_USERNAME',
                                                'GITLAB_PASSWORD' => 'tanuki',
                                                'GITLAB_USER_TYPE' => 'ldap',
                                                'GITLAB_URL' => 'http://localhost:9999' })
    end
  end

  describe '.require_kubernetes_environment!' do
    around do |example|
      ClimateControl.modify(
        GCLOUD_ACCOUNT_EMAIL: nil,
        GCLOUD_ACCOUNT_KEY: nil,
        CLOUDSDK_CORE_PROJECT: nil
      ) { example.run }
    end

    it 'raises an error when required variables are not present' do
      expect { described_class.require_kubernetes_environment! }.to raise_error(ArgumentError)
    end

    it 'raises an error with detailed message when one required element is not present' do
      ClimateControl.modify(
        CLOUDSDK_CORE_PROJECT: 'foo',
        GCLOUD_ACCOUNT_EMAIL: 'me@example.com'
        # GCLOUD_ACCOUNT_KEY: nil
      ) do
        expect { described_class.require_kubernetes_environment! }.to raise_error(/GCLOUD_ACCOUNT_KEY/)
      end
    end

    it 'doesnt raise an error when all variables are present' do
      ClimateControl.modify(
        CLOUDSDK_CORE_PROJECT: 'foo',
        GCLOUD_ACCOUNT_EMAIL: 'me@example.com',
        GCLOUD_ACCOUNT_KEY: 'bar'
      ) do
        expect { described_class.require_kubernetes_environment! }.not_to raise_error
      end
    end
  end
end
