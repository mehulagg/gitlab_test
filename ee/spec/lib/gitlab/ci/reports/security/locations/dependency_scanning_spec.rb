# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Reports::Security::Locations::DependencyScanning do
  describe '#initialize' do
    subject { described_class.new(**params) }

    let(:params) do
      {
        file_path: 'app/pom.xml',
        package_name: 'io.netty/netty',
        package_version: '1.2.3'
      }
    end

    context 'when all params are given' do
      it 'initializes an instance' do
        expect { subject }.not_to raise_error

        expect(subject).to have_attributes(
          file_path: 'app/pom.xml',
          fingerprint: '2773f8cc955346ab1f756b94aa310db8e17c0944',
          package_name: 'io.netty/netty',
          package_version: '1.2.3'
        )
      end
    end

    %i[file_path package_name].each do |attribute|
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

    where(:file_1, :package_1, :file_2, :package_2, :equal, :case_name) do
      'app/pom.xml' | 'io.netty/netty' | 'app/pom.xml'   | 'io.netty/netty' | true  | 'when file_path and package_name are equal'
      'app/pom.xml' | 'io.netty/netty' | 'other/pom.xml' | 'io.netty/netty' | false | 'when file_path is different'
      'app/pom.xml' | 'io.netty/netty' | 'app/pom.xml'   | 'junit/junit'    | false | 'when package_name is different'
    end

    with_them do
      let(:location_1) { create(:ci_reports_security_locations_dependency_scanning, file_path: file_1, package_name: package_1) }
      let(:location_2) { create(:ci_reports_security_locations_dependency_scanning, file_path: file_2, package_name: package_2) }

      it "returns #{params[:equal]}" do
        expect(location_1 == location_2).to eq(equal)
      end
    end
  end
end
