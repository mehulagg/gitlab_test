# frozen_string_literal: true

require 'spec_helper'

describe Types::BaseField do
  describe '#calculate_complexity' do
    let(:field) do
      described_class.new(**args.merge({ name: :foo, type: GraphQL::ID_TYPE, null: false }))
    end
    subject { field.field_complexity }

    context 'when field has no complexity' do
      let(:args) { { complexity: nil } }

      it { is_expected.to eq(1) }
    end

    context 'when field has a complexity' do
      let(:args) { { complexity: 2 } }

      it { is_expected.to eq(2) }
    end

    context 'when field has a complexity that is the same complexity as its resolver class' do
      let(:args) { { complexity: 2, resolver_class: double(complexity: 2) } }

      it { is_expected.to eq(2) }
    end

    context 'when field has a complexity that is different complexity to its resolver class' do
      let(:args) { { complexity: 1, resolver_class: double(complexity: 2, name: 'Resolver') } }

      it do
        expect { subject }.to raise_error(
          Gitlab::Graphql::Errors::ArgumentError,
          "Field :foo cannot define a complexity of 1, as its resolver Resolver already has a complexity of 2"
        )
      end

      context 'when the resolver class has a default complexity of 1' do
        let(:args) { { complexity: 2, resolver_class: double(complexity: 1, name: 'Resolver') } }

        it do
          expect { subject }.to raise_error(
            Gitlab::Graphql::Errors::ArgumentError,
            "Field :foo cannot define a complexity of 2, as its resolver Resolver already has a complexity of 1. " \
            "Perhaps you should fix this error by defining a complexity of 2 on Resolver"
          )
        end
      end
    end
  end
end
