# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LicenseScanningReportLicenseEntity do
  let(:project) { build(:project, :repository) }
  let(:license_policy) { ::SCA::LicensePolicy.new(reported_license, policy) }
  let(:reported_license) { build(:license_scanning_license, :mit).tap { |x| x.add_dependency(reported_dependency.name) } }
  let(:reported_dependency) { build(:license_scanning_dependency, :rails) }
  let(:policy) { build(:software_license_policy, :allowed, software_license: build(:software_license, :mit)) }
  let(:entity) { described_class.new(license_policy) }

  describe '#as_json' do
    subject { entity.as_json }

    specify { expect(subject[:classification][:approval_status]).to eq(license_policy.classification) }
    specify { expect(subject[:count]).to eql(license_policy.dependencies.count) }
    specify { expect(subject[:dependencies]).to contain_exactly(name: reported_dependency.name) }
    specify { expect(subject[:name]).to eql(license_policy.name) }
    specify { expect(subject[:url]).to eql(license_policy.url) }
  end
end
