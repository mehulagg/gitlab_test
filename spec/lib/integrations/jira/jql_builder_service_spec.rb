# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::Jira::JqlBuilder do
  describe '#execute' do
    subject { described_class.new('PROJECT_KEY', params).jql }

    context 'when no params' do
      let(:params) { {} }

      it 'builds jql with default ordering' do
        expect(subject).to eq("project = PROJECT_KEY order by created DESC")
      end
    end

    context 'with search param' do
      let(:params) { { search: 'new issue' } }

      it 'builds jql' do
        expect(subject).to eq("project = PROJECT_KEY AND (summary ~ 'new issue' OR description ~ 'new issue') order by created DESC")
      end
    end

    context 'with labels param' do
      let(:params) { { labels: %w[label1 label2 label3] } }

      it 'builds jql' do
        expect(subject).to eq("project = PROJECT_KEY AND labels = 'label1' AND labels = 'label2' AND labels = 'label3' order by created DESC")
      end
    end

    context 'with sort params' do
      let(:params) { { sort: 'updated', sort_direction: 'ASC' } }

      it 'builds jql' do
        expect(subject).to eq("project = PROJECT_KEY order by updated ASC")
      end
    end
  end
end
