# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CreateGithubWebhookWorker do
  include GrapePathHelpers::NamedRouteMatcher

  let(:project) do
    create(:project,
           import_source: 'foo/bar',
           import_type: 'github',
           import_data_attributes: { credentials: { user: 'gh_token' } })
  end

  subject do
    described_class.new
  end

  describe '#perform' do
    before do
      project.ensure_external_webhook_token
      project.save
    end

    shared_examples 'creates a webhook' do |client_klass|
      it 'creates a webhook' do
        expect_next_instance_of(client_klass) do |client|
          expect(client).to receive(:octokit).and_call_original
        end

        expect_next_instance_of(Octokit::Client) do |instance|
          expect(instance).to receive(:create_hook)
            .with(
              'foo/bar',
              'web',
              {
                url: "http://localhost#{api_v4_projects_mirror_pull_path(id: project.id)}",
                content_type: 'json',
                secret: project.external_webhook_token,
                insecure_ssl: 1
              },
              {
                events: %w[push pull_request],
                active: true
              }
            )
        end

        subject.perform(project.id)
      end
    end

    context 'when remove_legacy_github_client feature flag is enabled' do
      before do
        stub_feature_flags(remove_legacy_github_client: true)
      end

      include_examples 'creates a webhook', Gitlab::GithubImport::Client
    end

    context 'when remove_legacy_github_client feature flag is disabled' do
      before do
        stub_feature_flags(remove_legacy_github_client: false)
      end

      include_examples 'creates a webhook', Gitlab::LegacyGithubImport::Client
    end
  end
end
