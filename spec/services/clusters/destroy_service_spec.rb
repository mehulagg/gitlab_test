# frozen_string_literal: true

require 'spec_helper'

describe Clusters::DestroyService do
  include KubernetesHelpers

  describe '#execute' do
    subject { described_class.new(cluster.user, params).execute(cluster) }

    let!(:cluster) { create(:cluster, :project, :provided_by_user) }

    context 'when correct params' do
      context 'when params are empty' do
        let(:params) { { } }

        it 'destroys cluster' do
          subject
          expect(Clusters::Cluster.where(id: cluster.id).exists?).to_not be_falsey
        end
      end

      context 'when cleanup param is true' do
        let(:params) { { cleanup: 'true' } }

        it 'does no destroy cluster' do
          subject
          expect(Clusters::Cluster.where(id: cluster.id).exists?).to_not be_falsey
        end

        it 'transition cluster#cleanup_status from available to uninstalling_applications' do
          expect { subject }.to_change { cluster.cleanup_status }
            .from(:available)
            .to(:uninstalling_applications)
        end
      end
    end
  end
end
