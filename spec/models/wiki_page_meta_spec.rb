# frozen_string_literal: true

require 'spec_helper'

describe WikiPageMeta do
  let_it_be(:project) { create(:project) }
  let_it_be(:title) { FFaker::Lorem.sentence }

  describe 'Associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:slugs) }
  end

  describe 'Validations' do
    subject do
      described_class.new(canonical_slug: 'slimey',
                          title: 'some title',
                          project: project)
    end

    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:canonical_slug) }
    it { is_expected.to validate_uniqueness_of(:canonical_slug).scoped_to(:project_id) }
  end

  describe '#update_slug' do
    let(:slug) { 'shell-full' }

    let_it_be(:old_slug) { 'shell-less' }
    let_it_be(:meta) do
      described_class.create(
        canonical_slug: old_slug,
        title: title,
        project: project
      )
    end

    shared_examples 'correct slug state' do
      it 'causes the canonical_slug to be set to slug' do
        meta.update_slug(slug)

        expect(meta.canonical_slug).to eq(slug)
      end

      it 'causes the slug to exist in the slugs collection' do
        meta.update_slug(slug)

        expect(meta.slugs.pluck(:slug)).to include(slug)
      end
    end

    context 'no slugs have been created' do
      it 'creates a new slug' do
        expect { meta.update_slug(slug) }.to change(meta.slugs, :count).by(1)
      end

      include_examples 'correct slug state'
    end

    context 'there are slugs there, but not our one' do
      before do
        WikiPageSlug.create(wiki_page_meta: meta, slug: FFaker::Lorem.sentence)
      end

      it 'creates a new slug' do
        expect { meta.update_slug(slug) }.to change(meta.slugs, :count).by(1)
      end

      include_examples 'correct slug state'
    end

    context 'our slug is already in there' do
      before do
        WikiPageSlug.create(wiki_page_meta: meta, slug: slug)
      end

      it 'does not create a new slug' do
        expect { meta.update_slug(slug) }.not_to change(meta.slugs, :count)
      end

      include_examples 'correct slug state'
    end

    context 'our slug is the same as the existing slug' do
      let(:slug) { old_slug }

      include_examples 'correct slug state'
    end

    context 'if we call it twice' do
      before do
        meta.update_slug(slug)
      end

      it 'issues at most one query on the second invocation' do
        expect { meta.update_slug(slug) }.not_to exceed_query_limit(1)
      end
    end
  end

  describe '.for_wiki_page' do
    let_it_be(:slug) { 'shell-less' }
    let_it_be(:title) { 'Ten things you wanted to ask about slugs' }

    def find_record
      described_class.for_wiki_page(slug, title, project)
    end

    context 'no such record exists' do
      it 'creates a meta object' do
        expect { find_record }.to change(described_class, :count).by(1)
      end

      it 'initializes a record in the correct state' do
        record = find_record

        expect(record).to have_attributes(
          canonical_slug: slug,
          title: title,
          project: project
        )
      end
    end

    context 'such a record exists' do
      let_it_be(:existing) do
        described_class.create(
          canonical_slug: slug,
          title: title,
          project: project
        )
      end

      it 'does not create a new object' do
        expect { find_record }.to change(described_class, :count).by(0)
      end

      it 'returns the existing object' do
        expect(find_record).to eq(existing)
      end
    end

    context 'such a record exists, but the title needs updating' do
      let_it_be(:existing) do
        described_class.create(
          canonical_slug: slug,
          title: 'old title',
          project: project
        )
      end

      it 'does not create a new object' do
        expect { find_record }.to change(described_class, :count).by(0)
      end

      it 'returns the existing object' do
        expect(find_record.id).to eq(existing.id)
      end

      it 'updates the title', :aggregate_failures do
        record = find_record

        expect(record).to have_attributes(title: title)

        expect(described_class.find(record.id)).to have_attributes(title: title)
      end
    end
  end
end
