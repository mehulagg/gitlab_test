# frozen_string_literal: true

# KeysetConnection provides cursor based pagination, to avoid using OFFSET.
# It basically sorts / filters using WHERE sorting_value > cursor.
# We do this for performance reasons (https://gitlab.com/gitlab-org/gitlab-ce/issues/45756),
# as well as for having stable pagination
# https://graphql-ruby.org/pro/cursors.html#whats-the-difference
# https://coderwall.com/p/lkcaag/pagination-you-re-probably-doing-it-wrong
#
# It currently supports sorting on two columns. For example
#
#   Issue.order(created_at: :asc)
#   Issue.order(due_date: :asc).order(:id)
#
# It will tolerate non-attribute ordering, but only attributes determine the cursor.
# For example, this is legitimate:
#
#   Issue.order('issues.due_date IS NULL').order(due_date: :asc).order(:id)
#
# but anything more complex has a significant chance of not working.
#
# Note that the last ordering field should be unique, meaning it would never
# be NULL.  So these would work:
#
#   Issue.order(created_at: :asc)
#   Issue.order(due_date: :asc).order(:id)
#   Issue.order(due_date: :asc).order(created_at: :desc)
#
# but not
#
#   Issue.order(due_date: :asc).order(:relative_position)
#
# as either of those attributes could be NULL
#
module Gitlab
  module Graphql
    module Connections
      class KeysetConnection < GraphQL::Relay::BaseConnection
        def cursor_from_node(node)
          # Storing the current order values in the cursor allows us to
          # make an intelligent decision on handling NULL values.
          # Otherwise we would either need to fetch the record first,
          # or fetch it in the SQL, significantly complicating it.
          encoded_json_from_ordering(node)
        end

        def sliced_nodes
          @sliced_nodes ||=
            begin
              sliced = nodes
              sliced = before_slice(sliced) if before.present?
              sliced = after_slice(sliced) if after.present?

              sliced
            end
        end

        def paged_nodes
          # These are the nodes that will be loaded into memory for rendering
          # So we're ok loading them into memory here as that's bound to happen
          # anyway. Having them ready means we can modify the result while
          # rendering the fields.
          @paged_nodes ||= load_paged_nodes.to_a
        end

        private

        def load_paged_nodes
          if first && last
            raise Gitlab::Graphql::Errors::ArgumentError.new("Can only provide either `first` or `last`, not both")
          end

          if last
            sliced_nodes.last(limit_value)
          else
            sliced_nodes.limit(limit_value) # rubocop: disable CodeReuse/ActiveRecord
          end
        end

        def before_slice(sliced)
          decoded_cursor = ordering_from_encoded_json(before)
          ordering = conditions(decoded_cursor, compute_for: :before)

          sliced.where(*ordering) # rubocop: disable CodeReuse/ActiveRecord
        end

        def after_slice(sliced)
          decoded_cursor = ordering_from_encoded_json(after)
          ordering = conditions(decoded_cursor, compute_for: :after)

          sliced.where(*ordering) # rubocop: disable CodeReuse/ActiveRecord
        end

        def limit_value
          @limit_value ||= [first, last, max_page_size].compact.min
        end

        def table
          nodes.arel_table
        end

        def order_info
          # Only allow specific node type.  For example ignore String nodes
          @order_info ||= nodes.order_values.select do |value|
            value.is_a?(Arel::Nodes::Ascending) || value.is_a?(Arel::Nodes::Descending)
          end
        end

        def order_attribute_name(field)
          field&.expr&.name || nodes.primary_key
        end

        def sort_direction(field)
          field&.direction || :desc
        end

        def encoded_json_from_ordering(node)
          ordering = {}

          order_info.each do |field|
            field_name = order_attribute_name(field)
            ordering[field_name] = node[field_name].to_s
          end

          encode(ordering.to_json)
        end

        def ordering_from_encoded_json(cursor)
          JSON.parse(decode(cursor))
        rescue
          # for the transition period where a client might request using an
          # old style cursor.  Once removed, make it an error:
          #   raise Gitlab::Graphql::Errors::ArgumentError, "Please provide a valid cursor"
          # TODO can be removed in next release
          # https://gitlab.com/gitlab-org/gitlab/issues/32933
          field_name = order_attribute_name(order_info.first)

          { field_name => decode(cursor) }
        end

        # Based on whether the main field we're ordering on is nil in the
        # cursor, we can more easily target our query condition.
        # We assume that the last ordering field is unique, meaning
        # it will not contain NULLs.
        # We currently only support two ordering fields.
        def conditions(decoded_cursor, compute_for: :after)
          attr_names = order_info.map { |field| order_attribute_name(field) }
          attr_values = attr_names.map { |name| decoded_cursor[name] }
          attr_values.map!(&:presence)

          return if attr_names.empty?
          return if attr_names.count == 1 && attr_values.first.nil?

          comparison_operators = order_info.map { |field| sort_direction(field) }

          case compute_for
          when :before
            comparison_operators.map! { |comp| comp == :asc ? '<' : '>' }
          when :after
            comparison_operators.map! { |comp| comp == :asc ? '>' : '<' }
          end

          if attr_names.count == 1
            single_key_only_condition(attr_names, attr_values, comparison_operators)
          elsif attr_values.first
            not_null_condition(attr_names, attr_values, comparison_operators, compute_for: compute_for)
          else
            null_condition(attr_names, attr_values, comparison_operators, compute_for: compute_for)
          end
        end

        # Since there is only one order field, we have to assume it
        # does not contain NULLs, and we can do a simple ordering
        def single_key_only_condition(names, values, operator)
          condition = "#{names.first} #{operator.first} ?"

          [condition, values.first]
        end

        def not_null_condition(names, values, operator, compute_for:)
          null_check = compute_for == :after ? "OR (#{names.first} IS NULL)" : ''

          condition = <<~SQL
            ((#{names.first} #{operator.first} ?) OR (#{names.first} = ? AND #{names[1]} #{operator[1]} ?) #{null_check})
          SQL

          [condition, values.first, values.first, values[1]]
        end

        def null_condition(names, values, operator, compute_for:)
          null_check = compute_for == :before ? "OR (#{names.first} IS NOT NULL)" : ''

          condition = <<~SQL
            ((#{names.first} IS NULL AND #{names[1]} #{operator[1]} ?) #{null_check})
          SQL

          [condition, values[1]]
        end
      end
    end
  end
end
