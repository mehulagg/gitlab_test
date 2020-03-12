# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::GitalyClient::PraefectInfoService do
  let(:project) { create(:project, :repository) }
  let(:praefect_repository) { Gitlab::Git::Repository.new('praefect', project.repository.relative_path, nil, nil) }
  let(:client) { described_class.new(praefect_repository) }

  describe '#repository_replicas' do
    let(:repository_client) { Gitlab::GitalyClient::RepositoryService.new(praefect_repository) }

    it 'gets the replicas' do
      repository_client.create_repository
      checksum_resp = repository_client.calculate_checksum

      replicas_resp = client.replicas
      primary = replicas_resp.primary
      secondaries = replicas_resp.replicas

      expect(primary.checksum).to eq(checksum_resp)
      expect(secondaries).to be_empty
    end
  end
end
