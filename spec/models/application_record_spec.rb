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

    context 'when ActiveRecord::RecordNotUnique is raised' do
      before do
        expect(model).to receive(:save).once
      end

      it 'returns false by default' do
        expect(klass.safe_ensure_unique { model.save }).to be_falsey
      end

      it 'returns the value of on_rescue' do
        expect(klass.safe_ensure_unique(on_rescue: nil) { model.save }).to be_nil
      end

      it 'returns the return value of on_rescue lambda' do
        expect(klass.safe_ensure_unique(on_rescue: -> { true }) { model.save }).to be_truthy
      end
    end

    context 'retry count is specified' do
      before do
        expect(model).to receive(:save).exactly(3).times
      end

      it 'retries based on retry count specified' do
        expect(klass.safe_ensure_unique(retries: 2) { model.save }).to be_falsey
      end

      context 'before_retry lambda is specified' do
        let(:before_retry_lambda) { -> { nil } }

        it 'calls the lambda on each retry' do
          expect(before_retry_lambda).to receive(:call).exactly(2).times
          expect(klass.safe_ensure_unique(retries: 2, before_retry: before_retry_lambda) { model.save }).to be_falsey
        end
      end
    end
  end

  describe '.safe_find_or_create_by' do
    it 'creates the user avoiding race conditions' do
      expect(Suggestion).to receive(:find_or_create_by).and_raise(ActiveRecord::RecordNotUnique)
      allow(Suggestion).to receive(:find_or_create_by).and_call_original

      expect { Suggestion.safe_find_or_create_by(build(:suggestion).attributes) }
        .to change { Suggestion.count }.by(1)
    end
  end

  describe '.safe_find_or_create_by!' do
    it 'creates a record using safe_find_or_create_by' do
      expect(Suggestion).to receive(:find_or_create_by).and_call_original

      expect(Suggestion.safe_find_or_create_by!(build(:suggestion).attributes))
        .to be_a(Suggestion)
    end

    it 'raises a validation error if the record was not persisted' do
      expect { Suggestion.find_or_create_by!(note: nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '.underscore' do
    it 'returns the underscored value of the class as a string' do
      expect(MergeRequest.underscore).to eq('merge_request')
    end
  end
end
