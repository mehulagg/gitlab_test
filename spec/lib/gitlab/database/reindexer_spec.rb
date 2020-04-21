# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Database::Reindexer do
  describe '#reindex' do
    include Gitlab::Database::MigrationHelpers

    subject { described_class.new(conn: conn, index_manager: index_manager).reindex(indexname) }

    let(:tablename) { 'users' }
    let(:indexname) { 'users_example_index' }

    let(:conn) { ActiveRecord::Base.connection }
    let(:index_manager) { instance_double(Gitlab::Database::IndexManager, create: nil, drop: nil, swap_and_drop: nil) }

    let(:temp_index) { '_temp_index_for_reindexing' }

    before do
      conn.execute("CREATE INDEX IF NOT EXISTS #{indexname} ON #{tablename} (id, username)")
    end

    after do
      conn.execute("DROP INDEX IF EXISTS #{indexname}")
    end

    it 'creates a new index on the sides' do
      expect(index_manager).to receive(:create).with(temp_index, 'ON public.users USING btree (id, username)')

      subject
    end

    it 'drops the temp index if it exists' do
      expect(index_manager).to receive(:drop).with(temp_index)

      subject
    end

    context 'in a transaction' do
      before do
        expect(conn).to receive(:transaction).with(requires_new: true).and_yield
      end

      it 'swaps the temp index with the original index and drops the original (old) index' do
        expect(index_manager).to receive(:swap_and_drop).with(temp_index, indexname, tablename)

        subject
      end
    end
  end
end
