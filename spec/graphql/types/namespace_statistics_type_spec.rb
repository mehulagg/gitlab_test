require 'spec_helper'

describe GitlabSchema.types['NamespaceStatistics'] do
  it { expect(described_class).to require_graphql_authorizations(:read_statistics) }

  it "has all the required fields" do
    is_expected.to have_graphql_fields(:storage_size, :repository_size, :lfs_objects_size,
                                       :build_artifacts_size, :packages_size)
  end
end
