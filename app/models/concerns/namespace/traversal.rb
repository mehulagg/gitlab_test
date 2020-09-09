# frozen_string_literal: true
#
# Query a recursively defined namespace hierarchy using linear methods through
# the traversal_ids attribute.
#
# Namespace is a nested hierarchy of one parent to many children. A search
# using only the parent-child relationships is a slow operation. This process
# was previously optimized using Postgresql recursive common table expressions
# (CTE) with acceptable performance. However, it lead to slower than possible
# performance, and resulted in complicated queries that were difficult to make
# performant.
#
# Instead of searching the hierarchy recursively, we store a `traversal_ids`
# attribute on each node. The `traversal_ids` is an ordered array of Namespace
# IDs that define the traversal path from the root Namespace to the current
# Namespace.
#
# For example, suppose we have the following Namespaces:
#
# Gitlab (id: 1) > Engineering (id: 2) > Manage (id: 3) > Access (id: 4)
#
# Then `traverse_ids` for group "Access" is [1, 2, 3, 4]
#
# And we can match against other Namespace `traverse_ids` such that:
#
# - Ancestors are [1], [1, 2], [1, 2, 3]
# - Descendants are [1, 2, 3, 4, *]
# - Root is [1]
# - Hierarchy is [1, *]
#
# Note that this search method works so long as the IDs are unique and the
# traversal path is ordered from root to leaf nodes.
#
# We implement this in the database using Postgresql arrays, indexed by a
# generalized inverted index (gin).
class Namespace
  module Traversal
    extend ActiveSupport::Concern

    included do
      after_create :init_traversal_ids, if: :sync_traversal_ids?
      after_update :sync_traversal_ids, if: -> { sync_traversal_ids? && saved_change_to_parent? }

      scope :traversal_ids_contains, ->(ids) { where("traversal_ids @> (?)", ids) }
      scope :traversal_ids_contained_by, ->(ids) { where("traversal_ids <@ (?)", ids) }
    end

    def sync_traversal_ids?
      Feature.enabled?(:sync_traversal_ids, root_ancestor, default_enabled: false)
    end

    def linear_group_traversal?
      return false if traversal_ids.blank?

      Feature.enabled?(:linear_groups, root_ancestor, default_enabled: false)
    end

    # Returns all ancestors, self, and descendants of the current namespace.
    def self_and_hierarchy
      if linear_group_traversal?
        ancestors.or(self_and_descendants)
      else
        super
      end
    end

    # Returns all the ancestors of the current namespaces.
    def ancestors(hierarchy_order: nil)
      if linear_group_traversal?
        lineage(bottom: latest_parent_id, hierarchy_order: hierarchy_order)
      else
        super()
      end
    end

    # returns all ancestors upto but excluding the given namespace
    # when no namespace is given, all ancestors upto the top are returned
    def ancestors_upto(top = nil, hierarchy_order: nil)
      if linear_group_traversal?
        lineage(top: top, bottom: latest_parent_id, hierarchy_order: hierarchy_order)
          .where.not(id: top)
      else
        super
      end
    end

    def self_and_ancestors(hierarchy_order: nil)
      if linear_group_traversal?
        lineage(bottom: self, hierarchy_order: hierarchy_order)
      else
        super(hierarchy_order: hierarchy_order)
      end
    end

    # Returns all the descendants of the current namespace.
    def descendants
      if linear_group_traversal?
        self_and_descendants.where.not(id: id)
      else
        super
      end
    end

    def self_and_descendants
      if linear_group_traversal?
        lineage(top: self)
      else
        super
      end
    end

    private

    # Make sure we drop the STI `type = 'Group'` condition for better performance.
    # Logically equivalent so long as hierarchies remain homogeneous.
    def without_sti_condition
      self.class.unscope(where: :type)
    end

    # Search this namespace's lineage. Bound inclusively by top or bottom
    # nodes. Leave top or bottom nil for unbounded query, but not both.
    def lineage(top: nil, bottom: nil, hierarchy_order: nil)
      raise StandardError.new('Must bound search by either top or bottom') unless top || bottom

      skope = without_sti_condition

      if top
        skope = skope.traversal_ids_contains(latest_traversal_ids(top))
      end

      if bottom
        skope = skope.traversal_ids_contained_by(latest_traversal_ids(bottom))
      end

      # The original `with_depth` attribute in ObjectHierarchy increments as you
      # walk away from the "base" namespace. This direction changes depending on
      # if you are walking up the ancestors or down the descendants.
      if hierarchy_order
        depth_sql = "ABS(array_length((#{latest_traversal_ids.to_sql}), 1) - array_length(traversal_ids, 1))"
        skope = skope.select(skope.arel_table[Arel.star], "#{depth_sql} as depth")
                      .order(depth: hierarchy_order)
      end

      skope
    end

    def init_traversal_ids
      parent.lock!('FOR SHARE') if parent_id
      update_column(:traversal_ids, (parent&.traversal_ids || []) + [id])
    end

    def sync_traversal_ids
      TraversalHierarchy.for_namespace(self).sync_traversal_ids!
    end

    # traversal_ids are a cached value.
    #
    # The traversal_ids value in a loaded object can become stale when compared
    # to the database value. For example, if you load a hierarchy and then move
    # a group, any previously loaded descendant objects will have out of date
    # traversal_ids.
    #
    # To solve this problem, we never depend on the object's traversal_ids
    # value. We always query the database first with a sub-select for the
    # latest traversal_ids. The alternative which is cleaner though contains
    # nasty surprises, would be to use the potentially stale traversal_ids
    # object value and force `object#reload` calls as needed.
    def latest_traversal_ids(namespace = self)
      without_sti_condition.where('id = (?)', namespace)
              .select('traversal_ids as latest_traversal_ids')
    end

    def latest_parent_id(namespace = self)
      without_sti_condition.where(id: self).select(:parent_id)
    end
  end
end
