# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LabelLink do
  it { expect(build(:label_link)).to be_valid }

  it { is_expected.to belong_to(:label) }
  it { is_expected.to belong_to(:target) }

  it_behaves_like 'a BulkInsertSafe model', LabelLink do
    let(:valid_items_for_bulk_insertion) { build_list(:label_link, 10) }
    let(:invalid_items_for_bulk_insertion) { [] } # class does not have any validations defined
  end

  describe 'scope' do
    describe '.for_issues' do
      it 'returns label links for issues only' do
        create(:labeled_merge_request)
        label_link = create(:labeled_issue).label_links.first!

        expect(described_class.for_issues).to contain_exactly(label_link)
      end
    end

    describe '.created_after' do
      it 'only returns label links created within the specified dates' do
        Timecop.freeze do
          date = 1.week.ago

          create(:label_link, created_at: date + 1)
          label_link1 = create(:label_link, created_at: date)
          label_link2 = create(:label_link, created_at: date - 1)

          expect(described_class.created_after(date))
            .to contain_exactly(label_link1, label_link2)
        end
      end
    end

    describe '.with_label_attributes' do
      let_it_be(:project) { create(:project) }
      let(:label_attributes) { { title: 'hello world', description: 'hi' } }
      let(:label) { create(:label, project: project, **actual_label_attributes) }

      subject { described_class.with_label_attributes(label_attributes).count }

      before do
        create(:labeled_issue, project: label.project, labels: [label])
      end

      context 'with given label attributes' do
        let(:actual_label_attributes) { label_attributes }

        it { is_expected.to eq(1) }
      end

      context 'without given label attributes' do
        let(:actual_label_attributes) { { title: 'GitLab', description: 'tanuki' } }

        it { is_expected.to eq(0) }
      end
    end
  end
end
