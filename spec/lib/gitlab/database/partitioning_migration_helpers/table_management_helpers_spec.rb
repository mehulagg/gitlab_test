# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Database::PartitioningMigrationHelpers::TableManagementHelpers do
  let(:model) do
    ActiveRecord::Migration.new.extend(described_class)
  end
  let_it_be(:connection) { ActiveRecord::Base.connection }
  let(:template_table) { :audit_events }

  before do
    allow(model).to receive(:puts)
  end

  describe 'partitioning a table by date' do
    let(:partitioned_table) { model.partitioned_table_name(template_table, suffix: 'spec_part') }
    let(:partition_column) { 'created_at' }
    let(:old_primary_key) { 'id' }
    let(:new_primary_key) { [old_primary_key, partition_column] }
    let(:min_time) { Time.utc(2019, 12) }
    let(:max_time) { Time.utc(2020, 3) }

    context 'when the given table does not have a primary key' do
      let(:template_table) { :_partitioning_migration_helper_test_table }
      let(:partition_column) { :some_field }

      it 'raises an error' do
        model.create_table template_table, id: false do |t|
          t.integer :id
          t.datetime partition_column
        end

        expect do
          model.partition_table_by_date template_table, partition_column, partitioned_table: partitioned_table,
            min_time: min_time, max_time: max_time
        end.to raise_error(/primary key not defined for #{template_table}/)
      end
    end

    context 'when an invalid partition column is given' do
      let(:partition_column) { :_this_is_not_real }

      it 'raises an error' do
        expect do
          model.partition_table_by_date template_table, partition_column, partitioned_table: partitioned_table,
            min_time: min_time, max_time: max_time
        end.to raise_error(/partition column #{partition_column} does not exist/)
      end
    end

    context 'when a valid source table and partition column is given' do
      it 'creates a table partitioned by the proper column' do
        model.partition_table_by_date template_table, partition_column, partitioned_table: partitioned_table,
          min_time: min_time, max_time: max_time

        expect(connection.table_exists?(partitioned_table)).to be(true)
        expect(connection.primary_key(partitioned_table)).to eq(new_primary_key)

        expect_table_partitioned_by(partitioned_table, [partition_column])
      end

      it 'removes the default from the primary key column' do
        model.partition_table_by_date template_table, partition_column, partitioned_table: partitioned_table,
          min_time: min_time, max_time: max_time

        pk_column = connection.columns(partitioned_table).find { |c| c.name == old_primary_key }

        expect(pk_column.default_function).not_to be
      end

      it 'creates the partitioned table with the same non-key columns' do
        model.partition_table_by_date template_table, partition_column, partitioned_table: partitioned_table,
          min_time: min_time, max_time: max_time

        copied_columns = filter_columns_by_name(connection.columns(partitioned_table), new_primary_key)
        original_columns = filter_columns_by_name(connection.columns(template_table), new_primary_key)

        expect(copied_columns).to match_array(original_columns)
      end

      it 'creates a partition spanning over each month in the range given' do
        model.partition_table_by_date template_table, partition_column, partitioned_table: partitioned_table,
          min_time: min_time, max_time: max_time

        expect_range_partition_of("#{partitioned_table}_201912", partitioned_table, '2019-12-01', '2020-01-01')
        expect_range_partition_of("#{partitioned_table}_202001", partitioned_table, '2020-01-01', '2020-02-01')
        expect_range_partition_of("#{partitioned_table}_202002", partitioned_table, '2020-02-01', '2020-03-01')
      end
    end
  end

  def filter_columns_by_name(columns, names)
    columns.reject { |c| names.include?(c.name) }
  end

  def expect_table_partitioned_by(table, columns, part_type: :range)
    columns_with_part_type = columns.map { |c| [part_type.to_s, c] }
    actual_columns = find_partitioned_columns(table)

    expect(columns_with_part_type).to match_array(actual_columns)
  end

  def expect_range_partition_of(partition_name, table_name, min_value, max_value)
    min_value = convert_to_pg_format(min_value)
    max_value = convert_to_pg_format(max_value)

    definition = find_partition_definition(partition_name)

    expect(definition).to be
    expect(definition['base_table']).to eq(table_name.to_s)
    expect(definition['condition']).to eq("FOR VALUES FROM ('#{min_value}') TO ('#{max_value}')")
  end

  def convert_to_pg_format(timestr)
    Time.parse(timestr).strftime('%Y-%m-%d %H:%M:%S')
  end

  def find_partitioned_columns(table)
    connection.execute(<<~SQL).values
      select
        case partstrat
        when 'l' then 'list'
        when 'r' then 'range'
        when 'h' then 'hash'
        end as partstrat,
        cols.column_name
      from (
        select partrelid, partstrat, unnest(partattrs) as col_pos
        from pg_partitioned_table
      ) pg_part
      inner join pg_class
      on pg_part.partrelid = pg_class.oid
      inner join information_schema.columns cols
      on cols.table_name = pg_class.relname
      and cols.ordinal_position = pg_part.col_pos
      where pg_class.relname = '#{table}';
    SQL
  end

  def find_partition_definition(partition)
    connection.execute(<<~SQL).first
      select inhparent::regclass as base_table,
      pg_get_expr(pg_class.relpartbound, inhrelid) as condition
      from pg_class
      inner join pg_inherits i on pg_class.oid = inhrelid
      where pg_class.relname = '#{partition}' and pg_class.relispartition;
    SQL
  end
end
