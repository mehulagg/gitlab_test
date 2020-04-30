# frozen_string_literal: true

require 'spec_helper'

describe Ci::Minutes::Context do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let(:project) { build(:project, namespace: group) }

  describe 'delegation' do
    subject { described_class.new(user, project, group) }

    it { is_expected.to delegate_method(:shared_runners_remaining_minutes_below_threshold?).to(:level) }
    it { is_expected.to delegate_method(:shared_runners_minutes_used?).to(:level) }
    it { is_expected.to delegate_method(:shared_runners_minutes_limit_enabled?).to(:level) }
  end

  shared_examples 'captures root namespace' do
    describe '#namespace' do
      it 'assigns the namespace' do
        expect(subject.namespace).to eq group
      end
    end
  end

  context 'when at project level' do
    subject { described_class.new(user, project, nil) }

    it_behaves_like 'captures root namespace'

    describe '#can_see_status' do
      context 'when eligible to see status' do
        before do
          project.add_developer(user)
        end

        it 'can see status' do
          expect(subject.can_see_status?).to be_truthy
        end
      end

      context 'when not eligible to see status' do
        it 'cannot see status' do
          expect(subject.can_see_status?).to be_falsey
        end
      end
    end
  end

  context 'when at namespace level' do
    subject { described_class.new(user, nil, group) }

    it_behaves_like 'captures root namespace'

    describe '#can_see_status' do
      context 'when eligible to see status' do
        before do
          create(:ci_pipeline, user: user, project: project)
        end

        it 'can see status' do
          expect(subject.can_see_status?).to be_truthy
        end
      end

      context 'when not eligible to see status' do
        it 'cannot see status' do
          expect(subject.can_see_status?).to be_falsey
        end
      end
    end
  end
end
