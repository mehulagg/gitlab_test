# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::Reindexing::Index do
  before do
    ActiveRecord::Base.connection.execute(<<~SQL)
      CREATE INDEX foo_idx ON public.users (name);
      CREATE UNIQUE INDEX bar_key ON public.users (id);
    SQL
  end

  describe '#exists?' do
    it 'returns false if the index does not exist' do
      expect(described_class.new('nonexisting_index').exists?).to be_falsey
    end

    it 'returns true if the index exists' do
      expect(described_class.new('foo_idx').exists?).to be_truthy
    end
  end

  describe '#unique?' do
    it 'returns true if is_unique is set' do
      expect(described_class.new('bar_key').unique?).to be_truthy
    end

    it 'returns false if is_unique is not set' do
      expect(described_class.new('foo_idx').unique?).to be_falsey
    end

    it 'returns nil if the index is absent' do
      expect(described_class.new('nonexisting_index').unique?).to be_nil
    end
  end

  describe '#valid?' do
    it 'returns true if is_valid is set' do
      expect(described_class.new('bar_key').valid?).to be_truthy
    end

    it 'returns false if is_valid is not set' do
      ActiveRecord::Base.connection.execute(<<~SQL)
        UPDATE pg_index SET indisvalid=false
        FROM pg_class
        WHERE pg_class.relname = 'bar_key' AND pg_index.indexrelid = pg_class.oid
      SQL

      expect(described_class.new('bar_key').valid?).to be_falsey
    end

    it 'returns nil if the index is absent' do
      expect(described_class.new('nonexisting_index').valid?).to be_nil
    end
  end

  describe '#to_s' do
    it 'returns the index name' do
      expect(described_class.new('bar_key').to_s).to eq('bar_key')
    end
  end

  describe '#name' do
    it 'returns the name' do
      expect(described_class.new('bar_key').name).to eq('bar_key')
    end

    it 'returns if the index is absent' do
      expect(described_class.new('nonexisting_index').name).to be_nil
    end
  end

  describe '#schema' do
    it 'returns the index schema' do
      expect(described_class.new('bar_key').schema).to eq('public')
    end

    it 'returns if the index is absent' do
      expect(described_class.new('nonexisting_index').schema).to be_nil
    end
  end

  describe '#definition' do
    it 'returns the index definition' do
      expect(described_class.new('bar_key').definition).to eq('CREATE UNIQUE INDEX bar_key ON public.users USING btree (id)')
    end

    it 'returns if the index is absent' do
      expect(described_class.new('nonexisting_index').definition).to be_nil
    end
  end
end
