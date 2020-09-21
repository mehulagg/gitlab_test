# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ::SCA::LicenseDiff do
  subject { described_class.new(base, head) }

  describe "#diff" do
    let(:base) { instance_double(SCA::LicenseCompliance, license_scan_report: report_1) }
    let(:head) { instance_double(SCA::LicenseCompliance, license_scan_report: report_2) }
    let(:report_1) { build(:ci_reports_license_scanning_report, :report_1) }
    let(:report_2) { build(:ci_reports_license_scanning_report, :report_2) }

    before do
      report_1.add_license(id: nil, name: 'BSD').add_dependency('Library1')
      report_2.add_license(id: nil, name: 'bsd').add_dependency('Library1')
    end

    def names_from(licenses)
      licenses.map(&:name)
    end

    specify { expect(names_from(subject.diff[:added])).to contain_exactly('Apache 2.0') }
    specify { expect(names_from(subject.diff[:unchanged])).to contain_exactly('MIT', 'BSD') }
    specify { expect(names_from(subject.diff[:removed])).to contain_exactly('WTFPL') }
  end
end
