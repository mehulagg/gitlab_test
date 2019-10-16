require 'spec_helper'

require 'rubocop'
require 'rubocop/rspec/support'

require_relative '../../../../rubocop/cop/migration/post_migration_methods'

describe RuboCop::Cop::Migration::PostMigrationMethods do
  include CopHelper

  subject(:cop) { described_class.new }

  def source(method, meth = 'change')
    "def #{meth}; #{method}; end"
  end

  described_class::FORBIDDEN_METHODS.each do |method|
    context 'in a regular migration' do
      before do
        allow(cop).to receive(:in_migration?).and_return(true)
        allow(cop).to receive(:in_post_deployment_migration?).and_return(false)
      end

      it "registers an offense when #{method} is used in the change method" do
        inspect_source(source(method, 'change'))

        aggregate_failures do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.map(&:line)).to eq([1])
        end
      end

      it "registers an offense when #{method} is used in the up method" do
        inspect_source(source(method, 'up'))

        aggregate_failures do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.map(&:line)).to eq([1])
        end
      end

      it "registers no offense when #{method} is used in the down method" do
        inspect_source(source(method, 'down'))

        expect(cop.offenses.size).to eq(0)
      end
    end

    context 'in a post-deployment migration' do
      before do
        allow(cop).to receive(:in_migration?).and_return(true)
        allow(cop).to receive(:in_post_deployment_migration?).and_return(true)
      end

      it 'registers no offense' do
        inspect_source(source(method))

        expect(cop.offenses.size).to eq(0)
      end
    end

    context 'outside of a migration' do
      it 'registers no offense' do
        inspect_source(source(method))

        expect(cop.offenses.size).to eq(0)
      end
    end
  end
end
