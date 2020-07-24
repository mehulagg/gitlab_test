# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GithubImport::Stage::ImportIssuesWorker do
  let(:project) { create(:project) }
  let(:worker) { described_class.new }

  describe '#import' do
    it 'imports issues' do
      importer = double(:importer)
      client = double(:client)
      waiter = Gitlab::JobWaiter.new(2, '123')

      expect(Gitlab::GithubImport::Importer::IssuesImporter)
        .to receive(:new)
        .with(project, client)
        .and_return(importer)

      expect(importer)
        .to receive(:execute)
        .and_return(waiter)

      expect(Gitlab::GithubImport::AdvanceStageWorker)
        .to receive(:perform_async)
        .with(project.id, { '123' => 2 }, :notes)

      worker.import(client, project)
    end
  end
end
