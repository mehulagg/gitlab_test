# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitlab::MigrationHelpers do
  let(:model) do
    ActiveRecord::Migration.new.extend(described_class)
  end

  describe '#add_timestamps_with_timezone' do
    let(:in_transaction) { false }

    before do
      allow(model).to receive(:transaction_open?).and_return(in_transaction)
      allow(model).to receive(:disable_statement_timeout)
    end

    it 'adds "created_at" and "updated_at" fields with the "datetime_with_timezone" data type' do
      described_class::DEFAULT_TIMESTAMP_COLUMNS.each do |column_name|
        expect(model).to receive(:add_column).with(:foo, column_name, :datetime_with_timezone, { null: false })
      end

      model.add_timestamps_with_timezone(:foo)
    end

    it 'can disable the NOT NULL constraint' do
      described_class::DEFAULT_TIMESTAMP_COLUMNS.each do |column_name|
        expect(model).to receive(:add_column).with(:foo, column_name, :datetime_with_timezone, { null: true })
      end

      model.add_timestamps_with_timezone(:foo, null: true)
    end

    it 'can add just one column' do
      expect(model).to receive(:add_column).with(:foo, :created_at, :datetime_with_timezone, anything)
      expect(model).not_to receive(:add_column).with(:foo, :updated_at, :datetime_with_timezone, anything)

      model.add_timestamps_with_timezone(:foo, columns: [:created_at])
    end

    it 'can add choice of acceptable columns' do
      expect(model).to receive(:add_column).with(:foo, :created_at, :datetime_with_timezone, anything)
      expect(model).to receive(:add_column).with(:foo, :deleted_at, :datetime_with_timezone, anything)
      expect(model).not_to receive(:add_column).with(:foo, :updated_at, :datetime_with_timezone, anything)

      model.add_timestamps_with_timezone(:foo, columns: [:created_at, :deleted_at])
    end

    it 'cannot add unacceptable column names' do
      expect do
        model.add_timestamps_with_timezone(:foo, columns: [:bar])
      end.to raise_error %r/Illegal timestamp column name/
    end

    context 'in a transaction' do
      let(:in_transaction) { true }

      before do
        allow(model).to receive(:add_column).with(any_args).and_call_original
        allow(model).to receive(:add_column)
          .with(:foo, anything, :datetime_with_timezone, anything)
          .and_return(nil)
      end

      it 'cannot add a default value' do
        expect do
          model.add_timestamps_with_timezone(:foo, default: :i_cause_an_error)
        end.to raise_error %r/add_timestamps_with_timezone/
      end

      it 'can add columns without defaults' do
        expect do
          model.add_timestamps_with_timezone(:foo)
        end.not_to raise_error
      end
    end
  end

  describe '#remove_timestamps' do
    it 'can remove the default timestamps' do
      described_class::DEFAULT_TIMESTAMP_COLUMNS.each do |column_name|
        expect(model).to receive(:remove_column).with(:foo, column_name)
      end

      # byebug
      model.remove_timestamps(:foo)
    end

    it 'can remove custom timestamps' do
      expect(model).to receive(:remove_column).with(:foo, :bar)

      model.remove_timestamps(:foo, columns: [:bar])
    end
  end

  describe '#add_concurrent_index' do
    context 'outside a transaction' do
      before do
        allow(model).to receive(:transaction_open?).and_return(false)
        allow(model).to receive(:disable_statement_timeout).and_call_original
      end

      it 'creates the index concurrently' do
        expect(model).to receive(:add_index)
          .with(:gl_migration_helpers, :foo, algorithm: :concurrently)

        model.add_concurrent_index(:gl_migration_helpers, :foo)
      end

      it 'creates unique index concurrently' do
        expect(model).to receive(:add_index)
          .with(:gl_migration_helpers, :foo, { algorithm: :concurrently, unique: true })

        model.add_concurrent_index(:gl_migration_helpers, :foo, unique: true)
      end

      it 'does nothing if the index exists already' do
        expect(model).to receive(:index_exists?)
          .with(:gl_migration_helpers, :foo, { algorithm: :concurrently, unique: true }).and_return(true)
        expect(model).not_to receive(:add_index)

        model.add_concurrent_index(:gl_migration_helpers, :foo, unique: true)
      end
    end

    context 'inside a transaction' do
      it 'raises RuntimeError' do
        expect(model).to receive(:transaction_open?).and_return(true)

        expect { model.add_concurrent_index(:gl_migration_helpers, :foo) }
          .to raise_error(RuntimeError)
      end
    end
  end

  describe '#remove_concurrent_index' do
    context 'outside a transaction' do
      before do
        allow(model).to receive(:transaction_open?).and_return(false)
        allow(model).to receive(:index_exists?).and_return(true)
        allow(model).to receive(:disable_statement_timeout).and_call_original
      end

      describe 'by column name' do
        it 'removes the index concurrently' do
          expect(model).to receive(:remove_index)
            .with(:gl_migration_helpers, { algorithm: :concurrently, column: :foo })

          model.remove_concurrent_index(:gl_migration_helpers, :foo)
        end

        it 'does nothing if the index does not exist' do
          expect(model).to receive(:index_exists?)
            .with(:gl_migration_helpers, :foo, { algorithm: :concurrently, unique: true }).and_return(false)
          expect(model).not_to receive(:remove_index)

          model.remove_concurrent_index(:gl_migration_helpers, :foo, unique: true)
        end

        describe 'by index name' do
          before do
            allow(model).to receive(:index_exists_by_name?).with(:gl_migration_helpers, "index_x_by_y").and_return(true)
          end

          it 'removes the index concurrently by index name' do
            expect(model).to receive(:remove_index)
              .with(:gl_migration_helpers, { algorithm: :concurrently, name: "index_x_by_y" })

            model.remove_concurrent_index_by_name(:gl_migration_helpers, "index_x_by_y")
          end

          it 'does nothing if the index does not exist' do
            expect(model).to receive(:index_exists_by_name?).with(:gl_migration_helpers, "index_x_by_y").and_return(false)
            expect(model).not_to receive(:remove_index)

            model.remove_concurrent_index_by_name(:gl_migration_helpers, "index_x_by_y")
          end
        end
      end
    end

    context 'inside a transaction' do
      it 'raises RuntimeError' do
        expect(model).to receive(:transaction_open?).and_return(true)

        expect { model.remove_concurrent_index(:gl_migration_helpers, :foo) }
          .to raise_error(RuntimeError)
      end
    end
  end

  describe '#add_concurrent_foreign_key' do
    before do
      allow(model).to receive(:foreign_key_exists?).and_return(false)
    end

    context 'inside a transaction' do
      it 'raises an error' do
        expect(model).to receive(:transaction_open?).and_return(true)

        expect do
          model.add_concurrent_foreign_key(:projects, :gl_migration_helpers, column: :user_id)
        end.to raise_error(RuntimeError)
      end
    end

    context 'outside a transaction' do
      before do
        allow(model).to receive(:transaction_open?).and_return(false)
      end

      context 'ON DELETE statements' do
        context 'on_delete: :nullify' do
          it 'appends ON DELETE SET NULL statement' do
            expect(model).to receive(:disable_statement_timeout).and_call_original
            expect(model).to receive(:execute).with(/statement_timeout/)
            expect(model).to receive(:execute).ordered.with(/VALIDATE CONSTRAINT/)
            expect(model).to receive(:execute).with(/RESET ALL/)

            expect(model).to receive(:execute).with(/ON DELETE SET NULL/)

            model.add_concurrent_foreign_key(:projects, :gl_migration_helpers,
                                             column: :user_id,
                                             on_delete: :nullify)
          end
        end

        context 'on_delete: :cascade' do
          it 'appends ON DELETE CASCADE statement' do
            expect(model).to receive(:disable_statement_timeout).and_call_original
            expect(model).to receive(:execute).with(/statement_timeout/)
            expect(model).to receive(:execute).ordered.with(/VALIDATE CONSTRAINT/)
            expect(model).to receive(:execute).with(/RESET ALL/)

            expect(model).to receive(:execute).with(/ON DELETE CASCADE/)

            model.add_concurrent_foreign_key(:projects, :gl_migration_helpers,
                                             column: :user_id,
                                             on_delete: :cascade)
          end
        end

        context 'on_delete: nil' do
          it 'appends no ON DELETE statement' do
            expect(model).to receive(:disable_statement_timeout).and_call_original
            expect(model).to receive(:execute).with(/statement_timeout/)
            expect(model).to receive(:execute).ordered.with(/VALIDATE CONSTRAINT/)
            expect(model).to receive(:execute).with(/RESET ALL/)

            expect(model).not_to receive(:execute).with(/ON DELETE/)

            model.add_concurrent_foreign_key(:projects, :gl_migration_helpers,
                                             column: :user_id,
                                             on_delete: nil)
          end
        end
      end

      context 'when no custom key name is supplied' do
        it 'creates a concurrent foreign key and validates it' do
          expect(model).to receive(:disable_statement_timeout).and_call_original
          expect(model).to receive(:execute).with(/statement_timeout/)
          expect(model).to receive(:execute).ordered.with(/NOT VALID/)
          expect(model).to receive(:execute).ordered.with(/VALIDATE CONSTRAINT/)
          expect(model).to receive(:execute).with(/RESET ALL/)

          model.add_concurrent_foreign_key(:projects, :gl_migration_helpers, column: :user_id)
        end

        it 'does not create a foreign key if it exists already' do
          name = model.concurrent_foreign_key_name(:projects, :user_id)
          expect(model).to receive(:foreign_key_exists?).with(:projects, :gl_migration_helpers,
                                                              column: :user_id,
                                                              on_delete: :cascade,
                                                              name: name).and_return(true)

          expect(model).not_to receive(:execute).with(/ADD CONSTRAINT/)
          expect(model).to receive(:execute).with(/VALIDATE CONSTRAINT/)

          model.add_concurrent_foreign_key(:projects, :gl_migration_helpers, column: :user_id)
        end
      end

      context 'when a custom key name is supplied' do
        context 'for creating a new foreign key for a column that does not presently exist' do
          it 'creates a new foreign key' do
            expect(model).to receive(:disable_statement_timeout).and_call_original
            expect(model).to receive(:execute).with(/statement_timeout/)
            expect(model).to receive(:execute).ordered.with(/NOT VALID/)
            expect(model).to receive(:execute).ordered.with(/VALIDATE CONSTRAINT.+foo/)
            expect(model).to receive(:execute).with(/RESET ALL/)

            model.add_concurrent_foreign_key(:projects, :gl_migration_helpers, column: :user_id, name: :foo)
          end
        end

        context 'for creating a duplicate foreign key for a column that presently exists' do
          context 'when the supplied key name is the same as the existing foreign key name' do
            it 'does not create a new foreign key' do
              expect(model).to receive(:foreign_key_exists?).with(:projects, :gl_migration_helpers,
                                                                  name: :foo,
                                                                  on_delete: :cascade,
                                                                  column: :user_id).and_return(true)

              expect(model).not_to receive(:execute).with(/ADD CONSTRAINT/)
              expect(model).to receive(:execute).with(/VALIDATE CONSTRAINT/)

              model.add_concurrent_foreign_key(:projects, :gl_migration_helpers, column: :user_id, name: :foo)
            end
          end

          context 'when the supplied key name is different from the existing foreign key name' do
            it 'creates a new foreign key' do
              expect(model).to receive(:disable_statement_timeout).and_call_original
              expect(model).to receive(:execute).with(/statement_timeout/)
              expect(model).to receive(:execute).ordered.with(/NOT VALID/)
              expect(model).to receive(:execute).ordered.with(/VALIDATE CONSTRAINT.+bar/)
              expect(model).to receive(:execute).with(/RESET ALL/)

              model.add_concurrent_foreign_key(:projects, :gl_migration_helpers, column: :user_id, name: :bar)
            end
          end
        end
      end

      describe 'validate option' do
        let(:args) { [:projects, :gl_migration_helpers] }
        let(:options) { { column: :user_id, on_delete: nil } }

        context 'when validate is supplied with a falsey value' do
          it_behaves_like 'skips validation', validate: false
          it_behaves_like 'skips validation', validate: nil
        end

        context 'when validate is supplied with a truthy value' do
          it_behaves_like 'performs validation', validate: true
          it_behaves_like 'performs validation', validate: :whatever
        end

        context 'when validate is not supplied' do
          it_behaves_like 'performs validation', {}
        end
      end
    end
  end

  describe '#validate_foreign_key' do
    context 'when name is provided' do
      it 'does not infer the foreign key constraint name' do
        expect(model).to receive(:foreign_key_exists?).with(:projects, name: :foo).and_return(true)

        aggregate_failures do
          expect(model).not_to receive(:concurrent_foreign_key_name)
          expect(model).to receive(:disable_statement_timeout).and_call_original
          expect(model).to receive(:execute).with(/statement_timeout/)
          expect(model).to receive(:execute).ordered.with(/ALTER TABLE projects VALIDATE CONSTRAINT/)
          expect(model).to receive(:execute).ordered.with(/RESET ALL/)
        end

        model.validate_foreign_key(:projects, :user_id, name: :foo)
      end
    end

    context 'when name is not provided' do
      it 'infers the foreign key constraint name' do
        expect(model).to receive(:foreign_key_exists?).with(:projects, name: anything).and_return(true)

        aggregate_failures do
          expect(model).to receive(:concurrent_foreign_key_name)
          expect(model).to receive(:disable_statement_timeout).and_call_original
          expect(model).to receive(:execute).with(/statement_timeout/)
          expect(model).to receive(:execute).ordered.with(/ALTER TABLE projects VALIDATE CONSTRAINT/)
          expect(model).to receive(:execute).ordered.with(/RESET ALL/)
        end

        model.validate_foreign_key(:projects, :user_id)
      end

      context 'when the inferred foreign key constraint does not exist' do
        it 'raises an error' do
          expect(model).to receive(:foreign_key_exists?).and_return(false)

          error_message = /Could not find foreign key "fk_name" on table "projects"/
          expect { model.validate_foreign_key(:projects, :user_id, name: :fk_name) }.to raise_error(error_message)
        end
      end
    end
  end

  describe '#concurrent_foreign_key_name' do
    it 'returns the name for a foreign key' do
      name = model.concurrent_foreign_key_name(:this_is_a_very_long_table_name,
                                               :with_a_very_long_column_name)

      expect(name).to be_an_instance_of(String)
      expect(name.length).to eq(13)
    end
  end

  describe '#foreign_key_exists?' do
    before do
      key = ActiveRecord::ConnectionAdapters::ForeignKeyDefinition.new(:projects, :gl_migration_helpers, { column: :non_standard_id, name: :fk_projects_gl_migration_helpers_non_standard_id, on_delete: :cascade })
      allow(model).to receive(:foreign_keys).with(:projects).and_return([key])
    end

    shared_examples_for 'foreign key checks' do
      it 'finds existing foreign keys by column' do
        expect(model.foreign_key_exists?(:projects, target_table, column: :non_standard_id)).to be_truthy
      end

      it 'finds existing foreign keys by name' do
        expect(model.foreign_key_exists?(:projects, target_table, name: :fk_projects_gl_migration_helpers_non_standard_id)).to be_truthy
      end

      it 'finds existing foreign_keys by name and column' do
        expect(model.foreign_key_exists?(:projects, target_table, name: :fk_projects_gl_migration_helpers_non_standard_id, column: :non_standard_id)).to be_truthy
      end

      it 'finds existing foreign_keys by name, column and on_delete' do
        expect(model.foreign_key_exists?(:projects, target_table, name: :fk_projects_gl_migration_helpers_non_standard_id, column: :non_standard_id, on_delete: :cascade)).to be_truthy
      end

      it 'finds existing foreign keys by target table only' do
        expect(model.foreign_key_exists?(:projects, target_table)).to be_truthy
      end

      it 'compares by column name if given' do
        expect(model.foreign_key_exists?(:projects, target_table, column: :user_id)).to be_falsey
      end

      it 'compares by foreign key name if given' do
        expect(model.foreign_key_exists?(:projects, target_table, name: :non_existent_foreign_key_name)).to be_falsey
      end

      it 'compares by foreign key name and column if given' do
        expect(model.foreign_key_exists?(:projects, target_table, name: :non_existent_foreign_key_name, column: :non_standard_id)).to be_falsey
      end

      it 'compares by foreign key name, column and on_delete if given' do
        expect(model.foreign_key_exists?(:projects, target_table, name: :fk_projects_gl_migration_helpers_non_standard_id, column: :non_standard_id, on_delete: :nullify)).to be_falsey
      end
    end

    context 'without specifying a target table' do
      let(:target_table) { nil }

      it_behaves_like 'foreign key checks'
    end

    context 'specifying a target table' do
      let(:target_table) { :gl_migration_helpers }

      it_behaves_like 'foreign key checks'
    end

    it 'compares by target table if no column given' do
      expect(model.foreign_key_exists?(:projects, :other_table)).to be_falsey
    end
  end

  describe '#disable_statement_timeout' do
    it 'disables statement timeouts to current transaction only' do
      expect(model).to receive(:execute).with('SET LOCAL statement_timeout TO 0')


      model.connection.transaction do
        model.disable_statement_timeout
      end
    end

    # this specs runs without an enclosing transaction (:delete truncation method for db_cleaner)
    context 'with real environment', :delete do
      before do
        model.execute("SET statement_timeout TO '20000'")
      end

      after do
        model.execute('RESET ALL')
      end

      it 'defines statement to 0 only for current transaction' do
        expect(model.execute('SHOW statement_timeout').first['statement_timeout']).to eq('20s')

        model.connection.transaction do
          model.disable_statement_timeout
          expect(model.execute('SHOW statement_timeout').first['statement_timeout']).to eq('0')
        end

        expect(model.execute('SHOW statement_timeout').first['statement_timeout']).to eq('20s')
      end

      context 'when passing a blocks' do
        it 'disables statement timeouts on session level and executes the block' do
          expect(model).to receive(:execute).with('SET statement_timeout TO 0')
          expect(model).to receive(:execute).with('RESET ALL').at_least(:once)

          expect { |block| model.disable_statement_timeout(&block) }.to yield_control
        end

        # this specs runs without an enclosing transaction (:delete truncation method for db_cleaner)
        context 'with real environment', :delete do
          before do
            model.execute("SET statement_timeout TO '20000'")
          end

          after do
            model.execute('RESET ALL')
          end

          it 'defines statement to 0 for any code run inside the block' do
            expect(model.execute('SHOW statement_timeout').first['statement_timeout']).to eq('20s')

            model.disable_statement_timeout do
              model.connection.transaction do
                expect(model.execute('SHOW statement_timeout').first['statement_timeout']).to eq('0')
              end

              expect(model.execute('SHOW statement_timeout').first['statement_timeout']).to eq('0')
            end
          end
        end
      end
    end
  end

  describe '#update_column_in_batches' do
    context 'when running outside of a transaction' do
      before do
        recreate_table

        expect(model).to receive(:transaction_open?).and_return(false)

        5.times do |n|
          model.execute("INSERT INTO gl_migration_helpers VALUES (#{n}, 'Description #{n}', FALSE, 0)")
        end
      end

      let(:ar_model) { Class.new(ActiveRecord::Base) { self.table_name = "gl_migration_helpers" } }

      it 'updates all the rows in a table' do
        model.update_column_in_batches(:gl_migration_helpers, :description, 'foo')

        expect(ar_model.where(description: 'foo').count).to eq(5)
      end

      it 'updates boolean values correctly' do
        model.update_column_in_batches(:gl_migration_helpers, :boolean_flag, true)

        expect(ar_model.where(boolean_flag: true).count).to eq(5)
      end

      context 'when a block is supplied' do
        it 'yields an Arel table and query object to the supplied block' do
          first_id = ar_model.first.id

          model.update_column_in_batches(:gl_migration_helpers, :boolean_flag, true) do |t, query|
            query.where(t[:id].eq(first_id))
          end

          expect(ar_model.where(boolean_flag: true).count).to eq(1)
        end
      end

      context 'when the value is Arel.sql (Arel::Nodes::SqlLiteral)' do
        it 'updates the value as a SQL expression' do
          model.update_column_in_batches(:gl_migration_helpers, :integer_count, Arel.sql('1+1'))

          expect(ar_model.sum(:integer_count)).to eq(2 * ar_model.count)
        end
      end
    end

    context 'when running inside the transaction' do
      it 'raises RuntimeError' do
        expect(model).to receive(:transaction_open?).and_return(true)

        expect do
          model.update_column_in_batches(:gl_migration_helpers, :integer_count, Arel.sql('1+1'))
        end.to raise_error(RuntimeError)
      end
    end
  end

  describe '#add_column_with_default' do
    before do
      recreate_table
    end

    let(:ar_model) { Class.new(ActiveRecord::Base) { self.table_name = "gl_migration_helpers" } }

    let(:column) { ar_model.columns.find { |c| c.name == "id" } }

    context 'outside of a transaction' do
      context 'when a column limit is not set' do
        before do
          expect(model).to receive(:transaction_open?)
            .and_return(false)
            .at_least(:once)

          expect(model).to receive(:transaction).and_yield

          expect(model).to receive(:add_column)
            .with(:gl_migration_helpers, :foo, :integer, default: nil)

          expect(model).to receive(:change_column_default)
            .with(:gl_migration_helpers, :foo, 10)

          expect(model).to receive(:column_for)
            .with(:gl_migration_helpers, :foo).and_return(column)
        end

        it 'adds the column while allowing NULL values' do
          expect(model).to receive(:update_column_in_batches)
            .with(:gl_migration_helpers, :foo, 10)

          expect(model).not_to receive(:change_column_null)

          model.add_column_with_default(:gl_migration_helpers, :foo, :integer,
                                        default: 10,
                                        allow_null: true)
        end

        it 'adds the column while not allowing NULL values' do
          expect(model).to receive(:update_column_in_batches)
            .with(:gl_migration_helpers, :foo, 10)

          expect(model).to receive(:change_column_null)
            .with(:gl_migration_helpers, :foo, false)

          model.add_column_with_default(:gl_migration_helpers, :foo, :integer, default: 10)
        end

        it 'removes the added column whenever updating the rows fails' do
          expect(model).to receive(:update_column_in_batches)
            .with(:gl_migration_helpers, :foo, 10)
            .and_raise(RuntimeError)

          expect(model).to receive(:remove_column)
            .with(:gl_migration_helpers, :foo)

          expect do
            model.add_column_with_default(:gl_migration_helpers, :foo, :integer, default: 10)
          end.to raise_error(RuntimeError)
        end

        it 'removes the added column whenever changing a column NULL constraint fails' do
          expect(model).to receive(:change_column_null)
            .with(:gl_migration_helpers, :foo, false)
            .and_raise(RuntimeError)

          expect(model).to receive(:remove_column)
            .with(:gl_migration_helpers, :foo)

          expect do
            model.add_column_with_default(:gl_migration_helpers, :foo, :integer, default: 10)
          end.to raise_error(RuntimeError)
        end
      end

      context 'when a column limit is set' do
        it 'adds the column with a limit' do
          allow(model).to receive(:transaction_open?).and_return(false)
          allow(model).to receive(:transaction).and_yield
          allow(model).to receive(:column_for).with(:gl_migration_helpers, :foo).and_return(column)
          allow(model).to receive(:update_column_in_batches).with(:gl_migration_helpers, :foo, 10)
          allow(model).to receive(:change_column_null).with(:gl_migration_helpers, :foo, false)
          allow(model).to receive(:change_column_default).with(:gl_migration_helpers, :foo, 10)

          expect(model).to receive(:add_column)
            .with(:gl_migration_helpers, :foo, :integer, default: nil, limit: 8)

          model.add_column_with_default(:gl_migration_helpers, :foo, :integer, default: 10, limit: 8)
        end
      end

      it 'adds a column with an array default value for a jsonb type' do
        model.execute("INSERT INTO gl_migration_helpers VALUES (1, 'Description 1', FALSE, 0)")
        allow(model).to receive(:transaction_open?).and_return(false)
        allow(model).to receive(:transaction).and_yield
        expect(model).to receive(:update_column_in_batches).with(:gl_migration_helpers, :foo, '[{"foo":"json"}]').and_call_original

        model.add_column_with_default(:gl_migration_helpers, :foo, :jsonb, default: [{ foo: "json" }])
      end

      it 'adds a column with an object default value for a jsonb type' do
        model.execute("INSERT INTO gl_migration_helpers VALUES (1, 'Description 1', FALSE, 0)")
        allow(model).to receive(:transaction_open?).and_return(false)
        allow(model).to receive(:transaction).and_yield
        expect(model).to receive(:update_column_in_batches).with(:gl_migration_helpers, :foo, '{"foo":"json"}').and_call_original

        model.add_column_with_default(:gl_migration_helpers, :foo, :jsonb, default: { foo: "json" })
      end
    end

    context 'inside a transaction' do
      it 'raises RuntimeError' do
        expect(model).to receive(:transaction_open?).and_return(true)

        expect do
          model.add_column_with_default(:gl_migration_helpers, :foo, :integer, default: 10)
        end.to raise_error(RuntimeError)
      end
    end
  end

  describe '#rename_column_concurrently' do
    context 'in a transaction' do
      it 'raises RuntimeError' do
        allow(model).to receive(:transaction_open?).and_return(true)

        expect { model.rename_column_concurrently(:gl_migration_helpers, :old, :new) }
          .to raise_error(RuntimeError)
      end
    end

    context 'outside a transaction' do
      let(:old_column) do
        double(:column,
               type: :integer,
               limit: 8,
               default: 0,
               null: false,
               precision: 5,
               scale: 1)
      end

      let(:trigger_name) { model.rename_trigger_name(:gl_migration_helpers, :old, :new) }

      before do
        allow(model).to receive(:transaction_open?).and_return(false)
      end

      context 'when the column to rename exists' do
        before do
          allow(model).to receive(:column_for).and_return(old_column)
        end

        it 'renames a column concurrently' do
          expect(model).to receive(:check_trigger_permissions!).with(:gl_migration_helpers)

          expect(model).to receive(:install_rename_triggers_for_postgresql)
            .with(trigger_name, '"gl_migration_helpers"', '"old"', '"new"')

          expect(model).to receive(:add_column)
            .with(:gl_migration_helpers, :new, :integer,
                 limit: old_column.limit,
                 precision: old_column.precision,
                 scale: old_column.scale)

          expect(model).to receive(:change_column_default)
            .with(:gl_migration_helpers, :new, old_column.default)

          expect(model).to receive(:update_column_in_batches)

          expect(model).to receive(:change_column_null).with(:gl_migration_helpers, :new, false)

          expect(model).to receive(:copy_indexes).with(:gl_migration_helpers, :old, :new)
          expect(model).to receive(:copy_foreign_keys).with(:gl_migration_helpers, :old, :new)

          model.rename_column_concurrently(:gl_migration_helpers, :old, :new)
        end

        context 'when default is false' do
          let(:old_column) do
            double(:column,
                 type: :boolean,
                 limit: nil,
                 default: false,
                 null: false,
                 precision: nil,
                 scale: nil)
          end

          it 'copies the default to the new column' do
            expect(model).to receive(:change_column_default)
              .with(:gl_migration_helpers, :new, old_column.default)

            model.rename_column_concurrently(:gl_migration_helpers, :old, :new)
          end
        end
      end

      context 'when the column to be renamed does not exist' do
        before do
          allow(model).to receive(:columns).and_return([])
        end

        it 'raises an error with appropriate message' do
          expect(model).to receive(:check_trigger_permissions!).with(:gl_migration_helpers)

          error_message = /Could not find column "missing_column" on table "gl_migration_helpers"/
          expect { model.rename_column_concurrently(:gl_migration_helpers, :missing_column, :new) }.to raise_error(error_message)
        end
      end
    end
  end

  describe '#copy_indexes' do
    context 'using a regular index using a single column' do
      it 'copies the index' do
        index = double(:index,
                       columns: %w(project_id),
                       name: 'index_on_issues_project_id',
                       using: nil,
                       where: nil,
                       opclasses: {},
                       unique: false,
                       lengths: [],
                       orders: [])

        allow(model).to receive(:indexes_for).with(:issues, 'project_id')
          .and_return([index])

        expect(model).to receive(:add_concurrent_index)
          .with(:issues,
               %w(gl_project_id),
               unique: false,
               name: 'index_on_issues_gl_project_id',
               length: [],
               order: [])

        model.copy_indexes(:issues, :project_id, :gl_project_id)
      end
    end

    context 'using a regular index with multiple columns' do
      it 'copies the index' do
        index = double(:index,
                       columns: %w(project_id foobar),
                       name: 'index_on_issues_project_id_foobar',
                       using: nil,
                       where: nil,
                       opclasses: {},
                       unique: false,
                       lengths: [],
                       orders: [])

        allow(model).to receive(:indexes_for).with(:issues, 'project_id')
          .and_return([index])

        expect(model).to receive(:add_concurrent_index)
          .with(:issues,
               %w(gl_project_id foobar),
               unique: false,
               name: 'index_on_issues_gl_project_id_foobar',
               length: [],
               order: [])

        model.copy_indexes(:issues, :project_id, :gl_project_id)
      end
    end

    context 'using an index with a WHERE clause' do
      it 'copies the index' do
        index = double(:index,
                       columns: %w(project_id),
                       name: 'index_on_issues_project_id',
                       using: nil,
                       where: 'foo',
                       opclasses: {},
                       unique: false,
                       lengths: [],
                       orders: [])

        allow(model).to receive(:indexes_for).with(:issues, 'project_id')
          .and_return([index])

        expect(model).to receive(:add_concurrent_index)
          .with(:issues,
               %w(gl_project_id),
               unique: false,
               name: 'index_on_issues_gl_project_id',
               length: [],
               order: [],
               where: 'foo')

        model.copy_indexes(:issues, :project_id, :gl_project_id)
      end
    end

    context 'using an index with a USING clause' do
      it 'copies the index' do
        index = double(:index,
                       columns: %w(project_id),
                       name: 'index_on_issues_project_id',
                       where: nil,
                       using: 'foo',
                       opclasses: {},
                       unique: false,
                       lengths: [],
                       orders: [])

        allow(model).to receive(:indexes_for).with(:issues, 'project_id')
          .and_return([index])

        expect(model).to receive(:add_concurrent_index)
          .with(:issues,
               %w(gl_project_id),
               unique: false,
               name: 'index_on_issues_gl_project_id',
               length: [],
               order: [],
               using: 'foo')

        model.copy_indexes(:issues, :project_id, :gl_project_id)
      end
    end

    context 'using an index with custom operator classes' do
      it 'copies the index' do
        index = double(:index,
                       columns: %w(project_id),
                       name: 'index_on_issues_project_id',
                       using: nil,
                       where: nil,
                       opclasses: { 'project_id' => 'bar' },
                       unique: false,
                       lengths: [],
                       orders: [])

        allow(model).to receive(:indexes_for).with(:issues, 'project_id')
          .and_return([index])

        expect(model).to receive(:add_concurrent_index)
          .with(:issues,
               %w(gl_project_id),
               unique: false,
               name: 'index_on_issues_gl_project_id',
               length: [],
               order: [],
               opclasses: { 'gl_project_id' => 'bar' })

        model.copy_indexes(:issues, :project_id, :gl_project_id)
      end
    end

    describe 'using an index of which the name does not contain the source column' do
      it 'raises RuntimeError' do
        index = double(:index,
                       columns: %w(project_id),
                       name: 'index_foobar_index',
                       using: nil,
                       where: nil,
                       opclasses: {},
                       unique: false,
                       lengths: [],
                       orders: [])

        allow(model).to receive(:indexes_for).with(:issues, 'project_id')
          .and_return([index])

        expect { model.copy_indexes(:issues, :project_id, :gl_project_id) }
          .to raise_error(RuntimeError)
      end
    end
  end

  describe '#copy_foreign_keys' do
    it 'copies foreign keys from one column to another' do
      fk = double(:fk,
                  from_table: 'issues',
                  to_table: 'projects',
                  on_delete: :cascade)

      allow(model).to receive(:foreign_keys_for).with(:issues, :project_id)
        .and_return([fk])

      expect(model).to receive(:add_concurrent_foreign_key)
        .with('issues', 'projects', column: :gl_project_id, on_delete: :cascade)

      model.copy_foreign_keys(:issues, :project_id, :gl_project_id)
    end
  end

  describe '#column_for' do
    it 'returns a column object for an existing column' do
      column = model.column_for(:users, :id)

      expect(column.name).to eq('id')
    end

    it 'raises an error when a column does not exist' do
      error_message = /Could not find column "kittens" on table "users"/
      expect { model.column_for(:users, :kittens) }.to raise_error(error_message)
    end
  end

  describe '#replace_sql' do
    it 'builds the sql with correct functions' do
      expect(model.replace_sql(Arel::Table.new(:users)[:first_name], "Alice", "Eve").to_s)
        .to include('regexp_replace')
    end

    describe 'results' do
      let(:ar_model) { Class.new(ActiveRecord::Base) { self.table_name = "gl_migration_helpers" } }

      before do
        recreate_table
      end

      it 'replaces the correct part of the string' do
        record = ar_model.create!(description: 'Description number 1')

        allow(model).to receive(:transaction_open?).and_return(false)
        query = model.replace_sql(Arel::Table.new(:gl_migration_helpers)[:description], 'number ', '#')

        model.update_column_in_batches(:gl_migration_helpers, :description, query)

        expect(record.reload.description).to eq('Description #1')
      end
    end
  end

  describe '#check_trigger_permissions!' do
    it 'does nothing when the user has the correct permissions' do
      expect { model.check_trigger_permissions!('users') }
        .not_to raise_error
    end

    it 'raises RuntimeError when the user does not have the correct permissions' do
      allow(Gitlab::MigrationHelpers::Grant).to receive(:create_and_execute_trigger?)
        .with('kittens')
        .and_return(false)

      expect { model.check_trigger_permissions!('kittens') }
        .to raise_error(RuntimeError, /Your database user is not allowed/)
    end
  end

  def recreate_table
    model.execute("DROP TABLE IF EXISTS gl_migration_helpers")

    ActiveRecord::Schema.define(version: 1) do
      self.verbose = false
      create_table :gl_migration_helpers do |t|
        t.string   :description
        t.boolean  :boolean_flag
        t.integer  :integer_count
      end
    end
  end
end
