# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::StoreScanService do
  let_it_be(:artifact) { create(:ee_ci_job_artifact, :sast) }

  let(:known_keys) { Set.new }

  describe '.execute' do
    let(:mock_service_object) { instance_double(described_class, execute: true) }

    subject(:execute) { described_class.execute(artifact, known_keys, false) }

    before do
      allow(described_class).to receive(:new).with(artifact, known_keys, false).and_return(mock_service_object)
    end

    it 'delegates the call to an instance of `Security::StoreScanService`' do
      execute

      expect(described_class).to have_received(:new).with(artifact, known_keys, false)
      expect(mock_service_object).to have_received(:execute)
    end
  end

  describe '#execute' do
    let(:deduplicate) { false }
    let(:service_object) { described_class.new(artifact, known_keys, deduplicate) }
    let(:duplicated_security_finding) { create(:security_finding, project_fingerprint: 'd533c3a12403b6c6033a50b53f9c73f894a40fc6') }
    let(:unique_security_finding) { create(:security_finding, project_fingerprint: 'd533c3a12403b6c6033a50b53f9c73f894a40fc6') }
    let(:known_keys) do
      build(:ci_reports_security_finding_key,
            location_fingerprint: 'd869ba3f0b3347eb2749135a437dc07c8ae0f420',
            identifier_fingerprint: 'e6dd15eda2137be0034977a85b300a94a4f243a3')
    end

    subject(:store_scan) { service_object.execute }

    before do
      allow(Security::StoreFindingsMetadataService).to receive(:execute)
    end

    it 'calls the `Security::StoreFindingsMetadataService` to store findings' do
      store_scan

      expect(Security::StoreFindingsMetadataService).to have_received(:execute)
    end

    context 'when the security scan already exists for the artifact' do
      before do
        create(:security_scan, build: artifact.job, scan_type: :sast)
      end

      it 'does not create a new security scan' do
        expect { store_scan }.not_to change { artifact.job.security_scans.count }
      end

      context 'when the `deduplicate` param is set as false' do
        it 'does not change the deduplicated flag of duplicated finding' do
          expect { store_scan }.not_to change { duplicated_security_finding.deduplicated }.from(false)
        end

        it 'does not change the deduplicated flag of unique finding' do
          expect { store_scan }.not_to change { unique_security_finding.deduplicated }.from(false)
        end
      end

      context 'when the `deduplicate` param is set as true' do
        let(:deduplicate) { true }

        it 'does not change the deduplicated flag of duplicated finding false' do
          expect { store_scan }.not_to change { duplicated_security_finding.deduplicated }.from(false)
        end

        it 'sets the deduplicated flag of unique finding as true' do
          expect { store_scan }.to change { unique_security_finding.deduplicated }.to(true)
        end
      end
    end

    context 'when the security scan does not exist for the artifact' do
      it 'creates a new security scan' do
        expect { store_scan }.to change { artifact.job.security_scans.sast.count }.by(1)
      end

      context 'when the `deduplicate` param is set as false' do
        it 'does not change the deduplicated flag of duplicated finding false' do
          expect { store_scan }.not_to change { duplicated_security_finding.deduplicated }.from(false)
        end

        it 'sets the deduplicated flag of unique finding as true' do
          expect { store_scan }.to change { unique_security_finding.deduplicated }.from(true)
        end
      end

      context 'when the `deduplicate` param is set as true' do
        let(:deduplicate) { true }

        it 'does not change the deduplicated flag of duplicated finding false' do
          expect { store_scan }.not_to change { duplicated_security_finding.deduplicated }.from(false)
        end

        it 'sets the deduplicated flag of unique finding as true' do
          expect { store_scan }.to change { unique_security_finding.deduplicated }.to(true)
        end
      end
    end
  end
end
