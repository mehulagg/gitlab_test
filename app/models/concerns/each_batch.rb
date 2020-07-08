# frozen_string_literal: true

module EachBatch
  extend ActiveSupport::Concern

  class_methods do
    # Iterates over the rows in a relation in batches, similar to Rails'
    # `in_batches` but in a more efficient way.
    #
    # Unlike `in_batches` provided by Rails this method does not support a
    # custom start/end range, nor does it provide support for the `load:`
    # keyword argument.
    #
    # This method will yield an ActiveRecord::Relation to the supplied block, or
    # return an Enumerator if no block is given.
    #
    # Example:
    #
    #     User.each_batch do |relation|
    #       relation.update_all(updated_at: Time.current)
    #     end
    #
    # The supplied block is also passed an optional batch index:
    #
    #     User.each_batch do |relation, index|
    #       puts index # => 1, 2, 3, ...
    #     end
    #
    # You can also specify an alternative column to use for ordering the rows:
    #
    #     User.each_batch(column: :created_at) do |relation|
    #       ...
    #     end
    #
    # This will produce SQL queries along the lines of:
    #
    #     User Load (0.7ms)  SELECT  "users"."id" FROM "users" WHERE ("users"."id" >= 41654)  ORDER BY "users"."id" ASC LIMIT 1 OFFSET 1000
    #       (0.7ms)  SELECT COUNT(*) FROM "users" WHERE ("users"."id" >= 41654) AND ("users"."id" < 42687)
    #
    # of - The number of rows to retrieve per batch.
    # column - The column to use for ordering the batches.
    # order_hint - An optional column to append to the `ORDER BY id`
    #   clause to help the query planner. PostgreSQL might perform badly
    #   with a LIMIT 1 because the planner is guessing that scanning the
    #   index in ID order will come across the desired row in less time
    #   it will take the planner than using another index. The
    #   order_hint does not affect the search results. For example,
    #   `ORDER BY id ASC, updated_at ASC` means the same thing as `ORDER
    #   BY id ASC`.
    def each_batch(of: 1000, column: primary_key, order_hint: nil)
      return if none?

      unless column
        raise ArgumentError,
          'the column: argument must be set to a column name to use for ordering rows'
      end

      arel_table = self.arel_table

      base_relation = reselect(column).reorder(column => :asc).limit(of)
      base_relation.order!(order_hint) if order_hint

      tuple = connection.execute("SELECT MIN(#{column}) as start, MAX(#{column}) as stop FROM (#{base_relation.to_sql}) subquery").first
      lower_boundary, upper_boundary = tuple.values_at('start', 'stop')

      return unless lower_boundary

      relation = where(arel_table[column].gteq(lower_boundary))
                 .where(arel_table[column].lteq(upper_boundary))

      1.step do |index|
        yield relation.except(:order), index

        base_relation = base_relation.unscope(:where).where(arel_table[column].gt(upper_boundary))
        tuple = connection.execute("SELECT MAX(#{column}) as stop FROM (#{base_relation.to_sql}) subquery").first

        lower_boundary = upper_boundary
        upper_boundary = tuple['stop']

        break unless upper_boundary

        relation = where(arel_table[column].gt(lower_boundary))
                   .where(arel_table[column].lteq(upper_boundary))
      end
    end
  end
end
