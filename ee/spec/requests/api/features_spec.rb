# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Features, stub_feature_flags: false do
  include EE::GeoHelpers

  let_it_be(:admin) { create(:admin) }

  before do
    Feature.reset
    Flipper.unregister_groups
    Flipper.register(:perf_team) do |actor|
      actor.respond_to?(:admin) && actor.admin?
    end
  end

  describe 'POST /feature' do
    let(:feature_name) { 'my_feature' }

    context 'when running on a Geo primary node' do
      before do
        stub_primary_node
        allow(Gitlab::Geo).to receive(:secondary_nodes) { [double] }
      end

      it 'creates Geo cache invalidation event' do
        expect do
          post api("/features/#{feature_name}", admin), params: { value: 'true' }
        end.to change(Geo::CacheInvalidationEvent, :count).by(1)
      end
    end
  end

  describe 'DELETE /feature/:name' do
    let(:feature_name) { 'my_feature' }

    context 'when running on a Geo primary node' do
      before do
        stub_primary_node
        allow(Gitlab::Geo).to receive(:secondary_nodes) { [double] }
      end

      it 'creates Geo cache invalidation event' do
        Feature.enable(feature_name)

        expect do
          delete api("/features/#{feature_name}", admin)
        end.to change(Geo::CacheInvalidationEvent, :count).by(1)
      end
    end
  end
end
