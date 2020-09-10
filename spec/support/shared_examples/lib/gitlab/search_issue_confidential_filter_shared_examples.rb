# frozen_string_literal: true

RSpec.shared_examples 'search issues scope filters by confidential' do
  context 'filter not provided (all behavior)' do
    let(:filters) { {} }

    it 'returns confidential and not confidential results', :aggregate_failures do
      expect(results.objects('issues')).to include confidential_result
      expect(results.objects('issues')).to include opened_issue
    end
  end

  context 'confidential filter' do
    let(:filters) { { confidential: 'yes' } }

    it 'returns only confidential results', :aggregate_failures do
      expect(results.objects('issues')).to include confidential_result
      expect(results.objects('issues')).not_to include opened_issue
    end
  end

  context 'not confidential filter' do
    let(:filters) { { confidential: 'no' } }

    it 'returns not confidential results', :aggregate_failures do
      expect(results.objects('issues')).not_to include confidential_result
      expect(results.objects('issues')).to include opened_issue
    end
  end

  context 'unsupported filter' do
    let(:filters) { { confidential: 'goodbye' } }

    it 'returns confidential and not confidential results', :aggregate_failures do
      expect(results.objects('issues')).to include confidential_result
      expect(results.objects('issues')).to include opened_issue
    end
  end
end
