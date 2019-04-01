# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Reports::Security::Locations::Sast do
  describe '#initialize' do
    subject { described_class.new(**params) }

    let(:params) do
      {
        file_path: 'maven/src/main/java/com/gitlab/security_products/tests/App.java',
        start_line: 29,
        end_line: 31,
        class_name: 'com.gitlab.security_products.tests.App',
        method_name: 'insecureCypher'
      }
    end

    context 'when all params are given' do
      it 'initializes an instance' do
        expect { subject }.not_to raise_error

        expect(subject).to have_attributes(
          file_path: 'maven/src/main/java/com/gitlab/security_products/tests/App.java',
          fingerprint: '8e509ac62752a3d9330f31e89a000c95b942e73c',
          start_line: 29,
          end_line: 31,
          class_name: 'com.gitlab.security_products.tests.App',
          method_name: 'insecureCypher'
        )
      end
    end

    %i[file_path start_line].each do |attribute|
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

    where(:file_1, :start_1, :end_1, :file_2, :start_2, :end_2, :equal, :case_name) do
      'src/App.java' | 12 | 15 | 'src/App.java'  | 12 | 15 | true  | 'when file_path, start_line and end_line are equal'
      'src/App.java' | 12 | 15 | 'src/Main.java' | 12 | 15 | false | 'when file_path is different'
      'src/App.java' | 12 | 15 | 'src/App.java'  | 14 | 15 | false | 'when start_line is different'
      'src/App.java' | 12 | 15 | 'src/App.java'  | 12 | 13 | false | 'when end_line is different'
    end

    with_them do
      let(:location_1) { create(:ci_reports_security_locations_sast, file_path: file_1, start_line: start_1, end_line: end_1) }
      let(:location_2) { create(:ci_reports_security_locations_sast, file_path: file_2, start_line: start_2, end_line: end_2) }

      it "returns #{params[:equal]}" do
        expect(location_1 == location_2).to eq(equal)
      end
    end
  end
end
