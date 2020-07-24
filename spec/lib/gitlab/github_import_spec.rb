# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GithubImport do
  let(:project) { double(:project) }

  describe '.new_client_for' do
    context 'when importing from GitHub' do
      before do
        allow(project).to receive(:gitea_import?).and_return(false)
      end

      it 'returns a new Client with a custom token' do
        expect(described_class::Client)
          .to receive(:new)
          .with('123', parallel: true)

        described_class.new_client_for(project, token: '123')
      end

      it 'returns a new Client with a token stored in the import data' do
        import_data = double(:import_data, credentials: { user: '123' })

        expect(project)
          .to receive(:import_data)
          .and_return(import_data)

        expect(described_class::Client)
          .to receive(:new)
          .with('123', parallel: true)

        described_class.new_client_for(project)
      end
    end

    context 'when importing from Gitea' do
      before do
        allow(project).to receive(:gitea_import?).and_return(true)
        allow(project).to receive(:import_url).and_return('https://gitea.example.com/testing/repo.git')
      end

      it 'returns a new Client with gitea opts' do
        expect(described_class::Client)
          .to receive(:new)
          .with('123', parallel: true, host: 'https://gitea.example.com:443', api_version: 'v1')

        described_class.new_client_for(project, token: '123')
      end
    end
  end

  describe '.ghost_user_id', :clean_gitlab_redis_cache do
    it 'returns the ID of the ghost user' do
      expect(described_class.ghost_user_id).to eq(User.ghost.id)
    end

    it 'caches the ghost user ID' do
      expect(Gitlab::Cache::Import::Caching)
        .to receive(:write)
        .once
        .and_call_original

      2.times do
        described_class.ghost_user_id
      end
    end
  end
end
