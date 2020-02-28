# frozen_string_literal: true

require 'spec_helper'

describe Resolvers::VulnerabilitiesResolver do
  include GraphqlHelpers

  describe '#resolve' do
    context 'when given a project' do
      let(:project) { create(:project) }
      let!(:vulnerability) { create(:vulnerability, project: project) }

      subject { resolve(described_class, obj: project) }

      it "returns the project's vulnerabilities" do
        is_expected.to contain_exactly(vulnerability)
      end
    end
  end
end
