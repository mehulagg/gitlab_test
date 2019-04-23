module EE
  module GeoHelpers
    def stub_current_geo_node(node)
      allow(::Gitlab::Geo).to receive(:current_node).and_return(node)
      allow(node).to receive(:current?).and_return(true) unless node.nil?
    end

    def stub_primary_node
      allow(::Gitlab::Geo).to receive(:primary?).and_return(true)
    end

    def stub_secondary_node
      allow(::Gitlab::Geo).to receive(:primary?).and_return(false)
      allow(::Gitlab::Geo).to receive(:secondary?).and_return(true)
    end

    def stub_fdw(value)
      allow(::Gitlab::Geo::Fdw).to receive(:enabled?).and_return(value)
    end

    def stub_fdw_disabled
      stub_fdw(false)
    end

    def stub_selective_sync(node, value)
      allow(node).to receive(:selective_sync?).and_return(value)
    end
  end
end
