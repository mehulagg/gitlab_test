# frozen_string_literal: true

require 'spec_helper'

describe ApplicationRecord do
  describe '#id_in' do
    let(:records) { create_list(:user, 3) }

    it 'returns records of the ids' do
      expect(User.id_in(records.last(2).map(&:id))).to eq(records.last(2))
    end
  end

  describe '.safe_ensure_unique' do
    let(:model) { build(:suggestion) }
    let(:klass) { model.class }

    before do
      allow(model).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)
    end

    it 'returns false when ActiveRecord::RecordNotUnique is raised' do
      expect(model).to receive(:save).once
      expect(klass.safe_ensure_unique { model.save }).to be_falsey
    end

    it 'retries based on retry count specified' do
      expect(model).to receive(:save).exactly(3).times
      expect(klass.safe_ensure_unique(retries: 2) { model.save }).to be_falsey
    end
  end

  describe '.safe_find_or_create_by' do
    let!(:suggestion) { build(:suggestion) }
    let!(:attributes) { suggestion.attributes.except('id') }

    it 'returns an existing object' do
      suggestion.save!

      expect(Suggestion.safe_find_or_create_by(attributes))
        .to be_present
    end

    it 'creates a new object' do
      expect { Suggestion.safe_find_or_create_by(attributes) }
        .to change { Suggestion.count }.by(1)
    end

    it 'properly handles concurrent object creation' do
      expect(Suggestion).to receive(:create_or_find_by).and_wrap_original do |m, *args, &blk|
        # we save an existing object before the current one
        suggestion.save!

        m.call(*args, &blk)
      end

      expect { Suggestion.safe_find_or_create_by(attributes) }
        .to change { Suggestion.count }.by(1)
    end
  end

  describe '.safe_find_or_create_by!' do
    it 'creates a record using safe_find_or_create_by' do
      expect(Suggestion).to receive(:create).and_call_original

      expect(Suggestion.safe_find_or_create_by!(build(:suggestion).attributes))
        .to be_a(Suggestion)
    end

    it 'raises a validation error if the record was not persisted' do
      expect { Suggestion.safe_find_or_create_by!(note: nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '.underscore' do
    it 'returns the underscored value of the class as a string' do
      expect(MergeRequest.underscore).to eq('merge_request')
    end
  end
end
