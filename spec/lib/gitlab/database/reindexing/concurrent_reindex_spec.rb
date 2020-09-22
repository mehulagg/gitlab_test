# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::Reindexing::ConcurrentReindex, '#perform' do
  subject { described_class.new(index, logger: logger) }

  let(:table_name) { '_test_reindex_table' }
  let(:column_name) { '_test_column' }
  let(:index_name) { '_test_reindex_index' }
  let(:index) { double('index', name: index_name, schema: 'public', unique?: false, definition: 'CREATE INDEX _test_reindex_index ON public._test_reindex_table USING btree (_test_column)') }
  let(:logger) { double('logger', debug: nil, info: nil, error: nil ) }
  let(:connection) { ActiveRecord::Base.connection }

  before do
    connection.execute(<<~SQL)
      CREATE TABLE #{table_name} (
        id serial NOT NULL PRIMARY KEY,
        #{column_name} integer NOT NULL);

      CREATE INDEX #{index.name} ON #{table_name} (#{column_name});
    SQL
  end

  context 'when the index is unique' do
    let(:index) { double('index', name: index_name, unique?: true, definition: 'CREATE INDEX _test_reindex_index ON public._test_reindex_table USING btree (_test_column)') }

    it 'raises an error' do
      expect do
        subject.perform
      end.to raise_error(described_class::ReindexError, /UNIQUE indexes are currently not supported/)
    end
  end

  context 'replacing the original index with a rebuilt copy' do
    let(:replacement_name) { 'tmp_reindex__test_reindex_index' }
    let(:replaced_name) { 'old_reindex__test_reindex_index' }

    let(:create_index) { "CREATE INDEX CONCURRENTLY #{replacement_name} ON public.#{table_name} USING btree (#{column_name})" }
    let(:drop_index) { "DROP INDEX CONCURRENTLY IF EXISTS #{replacement_name}" }

    let!(:original_index) { find_index_create_statement }

    it 'integration test: executing full index replacement without mocks' do
      allow(connection).to receive(:execute).and_wrap_original do |method, sql|
        method.call(sql.sub(/CONCURRENTLY/, ''))
      end

      subject.perform

      check_index_exists
    end

    context 'mocked specs' do
      before do
        allow(subject).to receive(:connection).and_return(connection)
        allow(subject).to receive(:disable_statement_timeout).and_yield
      end

      it 'replaces the existing index with an identical index' do
        expect(subject).to receive(:disable_statement_timeout).exactly(3).times.and_yield

        expect_to_execute_concurrently_in_order(drop_index)
        expect_to_execute_concurrently_in_order(create_index)

        expect_next_instance_of(::Gitlab::Database::WithLockRetries) do |instance|
          expect(instance).to receive(:run).with(raise_on_exhaustion: true).and_yield
        end

        expect_to_execute_in_order("ALTER INDEX #{index.name} RENAME TO #{replaced_name}")
        expect_to_execute_in_order("ALTER INDEX #{replacement_name} RENAME TO #{index.name}")
        expect_to_execute_in_order("ALTER INDEX #{replaced_name} RENAME TO #{replacement_name}")

        expect_to_execute_concurrently_in_order(drop_index)

        subject.perform

        check_index_exists
      end

      context 'when a dangling index is left from a previous run' do
        before do
          connection.execute("CREATE INDEX #{replacement_name} ON #{table_name} (#{column_name})")
        end

        it 'replaces the existing index with an identical index' do
          expect(subject).to receive(:disable_statement_timeout).exactly(3).times.and_yield

          expect_to_execute_concurrently_in_order(drop_index)
          expect_to_execute_concurrently_in_order(create_index)

          expect_next_instance_of(::Gitlab::Database::WithLockRetries) do |instance|
            expect(instance).to receive(:run).with(raise_on_exhaustion: true).and_yield
          end

          expect_to_execute_in_order("ALTER INDEX #{index.name} RENAME TO #{replaced_name}")
          expect_to_execute_in_order("ALTER INDEX #{replacement_name} RENAME TO #{index.name}")
          expect_to_execute_in_order("ALTER INDEX #{replaced_name} RENAME TO #{replacement_name}")

          expect_to_execute_concurrently_in_order(drop_index)

          subject.perform

          check_index_exists
        end
      end

      context 'when it fails to create the replacement index' do
        it 'safely cleans up and signals the error' do
          expect_to_execute_concurrently_in_order(drop_index)

          expect(connection).to receive(:execute).with(create_index).ordered
            .and_raise(ActiveRecord::ConnectionTimeoutError, 'connect timeout')

          expect_to_execute_concurrently_in_order(drop_index)

          expect { subject.perform }.to raise_error(described_class::ReindexError, /connect timeout/)

          check_index_exists
        end
      end

      context 'when the replacement index is not valid' do
        it 'safely cleans up and signals the error' do
          expect_to_execute_concurrently_in_order(drop_index)
          expect_to_execute_concurrently_in_order(create_index)

          replacement_index = double('replacement index', valid?: false)
          allow(Gitlab::Database::Reindexing::Index).to receive(:find_with_schema).with("public.#{replacement_name}").and_return(replacement_index)

          expect_to_execute_concurrently_in_order(drop_index)

          expect { subject.perform }.to raise_error(described_class::ReindexError, /replacement index was created as INVALID/)

          check_index_exists
        end
      end

      context 'when a database error occurs while swapping the indexes' do
        it 'safely cleans up and signals the error' do
          expect_to_execute_concurrently_in_order(drop_index)
          expect_to_execute_concurrently_in_order(create_index)

          expect_next_instance_of(::Gitlab::Database::WithLockRetries) do |instance|
            expect(instance).to receive(:run).with(raise_on_exhaustion: true).and_yield
          end

          expect(connection).to receive(:execute).ordered
          .with("ALTER INDEX #{index.name} RENAME TO #{replaced_name}")
          .and_raise(ActiveRecord::ConnectionTimeoutError, 'connect timeout')

          expect_to_execute_concurrently_in_order(drop_index)

          expect { subject.perform }.to raise_error(described_class::ReindexError, /connect timeout/)

          check_index_exists
        end
      end

      context 'when with_lock_retries fails to acquire the lock' do
        it 'safely cleans up and signals the error' do
          expect_to_execute_concurrently_in_order(drop_index)
          expect_to_execute_concurrently_in_order(create_index)

          expect_next_instance_of(::Gitlab::Database::WithLockRetries) do |instance|
            expect(instance).to receive(:run).with(raise_on_exhaustion: true)
              .and_raise(::Gitlab::Database::WithLockRetries::AttemptsExhaustedError, 'exhausted')
          end

          expect_to_execute_concurrently_in_order(drop_index)

          expect { subject.perform }.to raise_error(described_class::ReindexError, /exhausted/)

          check_index_exists
        end
      end
    end
  end

  def expect_to_execute_concurrently_in_order(sql)
    # Indexes cannot be created CONCURRENTLY in a transaction. Since the tests are wrapped in transactions,
    # verify the original call but pass through the non-concurrent form.
    expect(connection).to receive(:execute).with(sql).ordered.and_wrap_original do |method, sql|
      method.call(sql.sub(/CONCURRENTLY/, ''))
    end
  end

  def expect_to_execute_in_order(sql)
    expect(connection).to receive(:execute).with(sql).ordered.and_call_original
  end

  def find_index_create_statement
    ActiveRecord::Base.connection.select_value(<<~SQL)
      SELECT indexdef
      FROM pg_indexes
      WHERE schemaname = 'public'
      AND indexname = #{ActiveRecord::Base.connection.quote(index.name)}
    SQL
  end

  def check_index_exists
    expect(find_index_create_statement).to eq(original_index)
  end
end
