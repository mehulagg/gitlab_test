# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../rubocop/cop/safe_ensure_unique'

describe RuboCop::Cop::SafeEnsureUnique do
  include CopHelper

  subject(:cop) { described_class.new }

  context 'when rescuing ActiveRecord::RecordNotUnique' do
    context 'when using begin..rescue' do
      it 'registers an offense' do
        expect_offense(<<~PATTERN.strip_indent)
          begin
            foo.save
          rescue ActiveRecord::RecordNotUnique
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use safe_ensure_unique instead. For more details check https://gitlab.com/gitlab-org/gitlab-ce/issues/60342.
            retry
          end
        PATTERN
      end
    end

    context 'when using rescue within method' do
      it 'registers an offense' do
        expect_offense(<<~PATTERN.strip_indent)
          def method
            foo.save
          rescue ActiveRecord::RecordNotUnique
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use safe_ensure_unique instead. For more details check https://gitlab.com/gitlab-org/gitlab-ce/issues/60342.
            retry
          end
        PATTERN
      end
    end
  end

  context 'when rescuing a different error' do
    context 'when using begin..rescue' do
      it 'does not register an offense' do
        expect_no_offenses(<<~PATTERN.strip_indent)
          begin
            foo.save
          rescue ActiveRecord::RecordNotFound
          end
        PATTERN
      end
    end

    context 'when using rescue within method' do
      it 'does not register an offense' do
        expect_no_offenses(<<~PATTERN.strip_indent)
          def method
            foo.save
          rescue ActiveRecord::RecordNotFound
          end
        PATTERN
      end
    end
  end

  context 'when not rescuing a specific error' do
    context 'when using begin..rescue' do
      it 'does not register an offense' do
        expect_no_offenses(<<~PATTERN.strip_indent)
          begin
            foo.save
          rescue
            retry
          end
        PATTERN
      end
    end

    context 'when using rescue within method' do
      it 'does not register an offense' do
        expect_no_offenses(<<~PATTERN.strip_indent)
          def method
            foo.save
          rescue
            retry
          end
        PATTERN
      end
    end
  end
end
