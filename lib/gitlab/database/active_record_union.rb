module Gitlab
  module Database
    module PushDownUnion
      OffsetLimit = Struct.new(:offset, :limit) do
        def pushdown_limit
          return nil unless self.limit

          self.offset.to_i + self.limit
        end
      end

      def joins!(*args)
        super
        apply_to_pushdown_union_clauses(:joins, *args)

        self
      end

      def where!(*args)
        super
        apply_to_pushdown_union_clauses(:where, *args)

        self
      end

      def group!(*args)
        deferred_toplevel_ops << ->(rel) { rel.group(*args) }

        self
      end

      def having!(*args)
        deferred_toplevel_ops << ->(rel) { rel.having(*args) }

        self
      end

      def _select!(*args)
        super
        apply_to_pushdown_union_clauses(:select, *args)

        self
      end

      def distinct!(*args)
        super
        apply_to_pushdown_union_clauses(:distinct, *args)

        self
      end

      def order!(*args)
        super
        apply_to_pushdown_union_clauses(:order, *args)

        self
      end

      def reorder!(*args)
        super
        apply_to_pushdown_union_clauses(:reorder, *args)

        self
      end

      def reverse_order!(*args)
        super
        apply_to_pushdown_union_clauses(:reverse_order, *args)

        self
      end

      def limit!(value)
        offset_limit.limit = value

        super(offset_limit.pushdown_limit)

        self.pushdown_union_clauses.map! do |union|
          union.limit(offset_limit.pushdown_limit)
        end

        self
      end

      def offset!(value)
        offset_limit.offset = value

        if offset_limit.limit
          # Re-limit to consider the offset
          limit!(offset_limit.limit)
        end

        self
      end

      def preload(*args)
        raise '#preload is not yet supported on a push-down union'
      end

      def preload!(*args)
        raise '#preload is not yet supported on a push-down union'
      end

      def includes!(*args)
        raise '#includes! is not yet supported on a push-down union'
      end

      def includes(*args)
        raise '#includes is not yet supported on a push-down union'
      end

      def eager_load(*args)
        raise '#eager_load is not yet supported on a push-down union'
      end

      def eager_load!(*args)
        raise '#eager_load is not yet supported on a push-down union'
      end

      def or(*args)
        raise '#or is not yet supported on a push-down union'
      end

      def or!(*args)
        raise '#or is not yet supported on a push-down union'
      end

      def extending(*args)
        raise '#extending is not yet supported on a push-down union'
      end

      def extending!(*args)
        raise '#extending is not yet supported on a push-down union'
      end

      private

      def offset_limit
        @offset_limit ||= OffsetLimit.new(nil, nil)
      end

      def deferred_toplevel_ops
        @deferred_toplevel_ops ||= []
      end

      def build_arel(aliases)
        left = super

        union = self.pushdown_union_clauses.inject(left) do |res, right|
          Arel::Nodes::Union.new(res, right.arel)
        end

        from = Arel::Nodes::TableAlias.new(union, arel_table.name)

        rel = unscoped
          .from(from)
          .select(self.select_values)
          .distinct(self.distinct_value)
          .limit(offset_limit.limit)
          .offset(offset_limit.offset)
          .order(self.order_values)

        rel = deferred_toplevel_ops.inject(rel) do |r, op|
          op.call(r)
        end

        rel.arel
      end

      def apply_to_pushdown_union_clauses(method, *args)
        self.pushdown_union_clauses.map! do |union|
          union.send(method, *args)
        end
      end
    end

    module ActiveRecordUnion
      ::ActiveRecord::Relation::DEFAULT_VALUES[:pushdown_union] = ::ActiveRecord::Relation::FROZEN_EMPTY_ARRAY

      def union_pushdown(other, *args)
        spawn.union_pushdown!(other, *args)
      end

      def union_pushdown!(other, *args)
        raise ArgumentError, "Relation passed to #union_pushdown must be of type #{self.class}, but is #{other.class}" unless other.is_a?(self.class)
        raise ArgumentError, "Base relations for union cannot have existing order, group, limit or offset values" unless [self, other].all? { |r| r.limit_value.nil? && r.offset_value.nil? && r.order_values.empty? && r.group_values.empty? }

        incompatible_values = structurally_incompatible_values_for_or(other)

        unless incompatible_values.empty?
          raise ArgumentError, "Relation passed to #union_pushdown must be structurally compatible. Incompatible values: #{incompatible_values}"
        end

        self.pushdown_union_clauses += [other]

        extend PushDownUnion

        self
      end

      protected

      def pushdown_union_clauses
        get_value(:pushdown_union)
      end

      def pushdown_union_clauses=(clauses)
        set_value(:pushdown_union, clauses)
      end
    end
  end
end
