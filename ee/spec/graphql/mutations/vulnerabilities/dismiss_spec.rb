# frozen_string_literal: true
require 'spec_helper'

describe Mutations::Vulnerabilities::Dismiss do
  let(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  describe '#resolve' do
    let_it_be(:vulnerability) { create(:vulnerability, :with_findings) }
    let_it_be(:user) { create(:user) }

    let(:comment) { 'Dismissal Feedbacl' }
    let(:mutated_vulnerability) { subject[:vulnerability] }

    subject { mutation.resolve(id: GitlabSchema.id_from_object(vulnerability).to_s, comment: comment) }

    it 'raises an error if the resource is not accessible to the user' do
      expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when the user can dismiss the vulnerability' do
      before do
        stub_licensed_features(security_dashboard: true)
        vulnerability.project.add_developer(user)
      end

      it 'returns the dismissed vulnerability' do
        expect(mutated_vulnerability).to eq(vulnerability)
        expect(mutated_vulnerability).to be_dismissed
        expect(subject[:errors]).to be_empty
      end
    end
  end
end
