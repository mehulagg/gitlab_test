# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Reports::Security::Locations::Dast do
  describe '#initialize' do
    subject { described_class.new(**params) }

    let(:params) do
      {
        hostname: 'my-app.com',
        method_name: 'GET',
        param: 'X-Content-Type-Options',
        path: '/some/path'
      }
    end

    context 'when all params are given' do
      it 'initializes an instance' do
        expect { subject }.not_to raise_error

        expect(subject).to have_attributes(
          hostname: 'my-app.com',
          fingerprint: 'd2a664e4eaf53b6abe750b3e912c55fb1fa3641e',
          method_name: 'GET',
          param: 'X-Content-Type-Options',
          path: '/some/path'
        )
      end
    end

    %i[method_name path].each do |attribute|
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

    where(:path_1, :method_1, :param_1, :path_2, :method_2, :param_2, :equal, :case_name) do
      '/some/path' | 'GET' | 'X-Content-Type-Options'  | '/some/path'  | 'GET'  | 'X-Content-Type-Options' | true  | 'when path, method and param are equal'
      '/some/path' | 'GET' | 'X-Content-Type-Options'  | '/other/path' | 'GET'  | 'X-Content-Type-Options' | false | 'when path is different'
      '/some/path' | 'GET' | 'X-Content-Type-Options'  | '/some/path'  | 'POST' | 'X-Content-Type-Options' | false | 'when method is different'
      '/some/path' | 'GET' | 'X-Content-Type-Options'  | '/some/path'  | 'GET'  | 'X-Frame-Options'        | false | 'when param is different'
    end

    with_them do
      let(:location_1) { create(:ci_reports_security_locations_dast, path: path_1, method_name: method_1, param: param_1) }
      let(:location_2) { create(:ci_reports_security_locations_dast, path: path_2, method_name: method_2, param: param_2) }

      it "returns #{params[:equal]}" do
        expect(location_1 == location_2).to eq(equal)
      end
    end
  end
end
