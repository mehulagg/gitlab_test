# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::StoreScansGroupService do
  let_it_be(:build_1) { create(:ee_ci_build, name: 'DAST 1') }
  let_it_be(:build_2) { create(:ee_ci_build, name: 'DAST 3') }
  let_it_be(:build_3) { create(:ee_ci_build, name: 'DAST 2') }
  let_it_be(:artifact_1) { create(:ee_ci_job_artifact, :dast, job: build_1) }
  let_it_be(:artifact_2) { create(:ee_ci_job_artifact, :dast, job: build_2) }
  let_it_be(:artifact_3) { create(:ee_ci_job_artifact, :dast, job: build_3) }

  let(:artifacts) { [artifact_1, artifact_2, artifact_3] }

  describe '.execute' do
    let(:mock_service_object) { instance_double(described_class, execute: true) }

    subject(:execute) { described_class.execute(artifacts) }

    before do
      allow(described_class).to receive(:new).with(artifacts).and_return(mock_service_object)
    end

    it 'delegates the call to an instance of `Security::StoreScansGroupService`' do
      execute

      expect(described_class).to have_received(:new).with(artifacts)
      expect(mock_service_object).to have_received(:execute)
    end
  end

  describe '#execute' do
    let(:service_object) { described_class.new(artifacts) }
    let(:empty_set) { Set.new }

    subject(:store_scan_group) { service_object.execute }

    before do
      allow(Security::StoreScanService).to receive(:execute).and_return(true)
    end

    it 'calls the Security::StoreScanService with ordered artifacts' do
      store_scan_group

      expect(Security::StoreScanService).to have_received(:execute).with(artifact_1, empty_set, false).ordered
      expect(Security::StoreScanService).to have_received(:execute).with(artifact_3, empty_set, true).ordered
      expect(Security::StoreScanService).to have_received(:execute).with(artifact_2, empty_set, true).ordered
    end
  end
end
