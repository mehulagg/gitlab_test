# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::BaseEnum do
  using RSpec::Parameterized::TableSyntax

  describe '#value' do
    where(:arg, :raises) do
      'f'    | true
      'FOo'  | true
      'FOO'  | false
      'F_OO' | false
      '123a' | true
      '123'  | false
    end

    with_them do
      it 'raises an error when value contains a lowercase string' do
        test = -> { described_class.value(arg) }

        if raises
          expect(&test).to raise_error(ArgumentError, /must be uppercase/)
        else
          expect(&test).not_to raise_error
        end
      end
    end

    it 'does not raise if `deprecated` keyword is present' do
      expect do
        described_class.value('foo', deprecated: { reason: 'reason', milestone: '1' })
      end.not_to raise_error
    end
  end

  describe '#enum' do
    let(:enum) do
      Class.new(described_class) do
        value 'TEST', value: 3
        value 'NORMAL'
      end
    end

    it 'adds all enum values to #enum' do
      expect(enum.enum.keys).to contain_exactly('test', 'normal')
      expect(enum.enum.values).to contain_exactly(3, 'NORMAL')
    end

    it 'is a HashWithIndifferentAccess' do
      expect(enum.enum).to be_a(HashWithIndifferentAccess)
    end
  end

  include_examples 'Gitlab-style deprecations' do
    def subject(args = {})
      enum = Class.new(described_class) do
        graphql_name 'TestEnum'

        value 'TEST_VALUE', **args
      end

      enum.to_graphql.values['TEST_VALUE']
    end
  end
end
