# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Reports::Security::Locations::ContainerScanning do
  describe '#initialize' do
    subject { described_class.new(**params) }

    let(:params) do
      {
        image: 'registry.gitlab.com/my/project:latest',
        operating_system: 'debian:9',
        package_name: 'glibc',
        package_version: '1.2.3'
      }
    end

    context 'when all params are given' do
      it 'initializes an instance' do
        expect { subject }.not_to raise_error

        expect(subject).to have_attributes(
          image: 'registry.gitlab.com/my/project:latest',
          fingerprint: 'f2e9fcea1ad4262301edd4b3106de334914064ab',
          operating_system: 'debian:9',
          package_name: 'glibc',
          package_version: '1.2.3'
        )
      end
    end

    %i[image operating_system].each do |attribute|
      context "when attribute #{attribute} is missing" do
        before do
          params.delete(attribute)
        end

        it 'raises an error' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe '#==' do
    using RSpec::Parameterized::TableSyntax

    where(:os_1, :package_1, :os_2, :package_2, :equal, :case_name) do
      'debian:9' | 'glibc' | 'debian:9'    | 'glibc' | true  | 'when operating_system and package_name are equal'
      'debian:9' | 'glibc' | 'windows:lol' | 'glibc' | false | 'when operating_system is different'
      'debian:9' | 'glibc' | 'debian:9'    | 'perl'  | false | 'when package_name is different'
    end

    with_them do
      let(:location_1) { create(:ci_reports_security_locations_container_scanning, operating_system: os_1, package_name: package_1) }
      let(:location_2) { create(:ci_reports_security_locations_container_scanning, operating_system: os_2, package_name: package_2) }

      it "returns #{params[:equal]}" do
        expect(location_1 == location_2).to eq(equal)
      end
    end
  end
end
