# frozen_string_literal: true

require 'spec_helper'

describe WikiPageSlug do
  describe 'Associations' do
    it { is_expected.to belong_to(:wiki_page_meta) }
  end

  describe 'Validations' do
    let(:meta) do
      WikiPageMeta.create(project: create(:project),
                          canonical_slug: 'slippery',
                          title: 'looks like this')
    end

    subject { described_class.new(slug: 'slimey', wiki_page_meta: meta) }

    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug).scoped_to(:wiki_page_meta_id) }
  end
end
