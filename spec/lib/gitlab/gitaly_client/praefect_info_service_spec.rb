# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::GitalyClient::PraefectInfoService do
  let(:project) { create(:project, :repository) }
  let(:praefect_repository) { Gitlab::Git::Repository.new('praefect', project.repository.relative_path, nil, nil) }
  let(:client) { described_class.new(praefect_repository) }

  describe '#repository_replicas' do
    let(:repository_client) { Gitlab::GitalyClient::RepositoryService.new(praefect_repository) }

    it 'gets the replicas' do
      byebug
      resp = repository_client.create_repository
      byebug
      resp = client.replicas
      byebug
    end
  end
end
