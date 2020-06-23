# frozen_string_literal: true
#
# Query a recursively defined namespace hierarchy using linear methods.
#
# Namespace is a nested hierarchy of one parent to many children. A search
# using only the parent-child relationships is a slow O(log n) operation. This
# process was previously optimized using Postgresql recursive common table
# expressions (CTE) which was very fast all things considered. However, it was
# still limited to O(log n) speeds, experienced questions around scaling, and
# the queries were complex and difficult to work with.
#
# Instead of searching the hierarchy recursively, we store a `traversal_ids`
# attribute on each node. The `traversal_ids` is an ordered array of Namespace
# IDs that define the traversal path from the root Namespace to the current
# Namespace. We can search with this attribute in O(1) time.
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
#
# There are two feature flags:
# - :sync_linear_group_traversal, group
# - :linear_groups, group
#
class Namespace
  module Traversal
    extend ActiveSupport::Concern

    include FeatureGate

    included do
      after_create :init_traversal_ids, if: :sync_linear_group_traversal?
      after_update :sync_traversal_ids, if: -> { sync_linear_group_traversal? && saved_change_to_parent? }
    end

    def sync_linear_group_traversal?
      Feature.enabled?(:sync_linear_group_traversal, root_ancestor, default_enabled: false)
    end

    def linear_group_traversal?
      return false if traversal_ids.blank?

      Feature.enabled?(:linear_groups, root_ancestor, default_enabled: false)
    end

    def root_traversal_id
      traversal_ids&.first
    end

    def root_ancestor
      if linear_group_traversal?
        self.class.find_by('traversal_ids = ARRAY[?]::integer[]', root_traversal_id)
      else
        super
      end
    end

    # Returns all ancestors, self, and descendants of the current namespace.
    def self_and_hierarchy
      if linear_group_traversal?
        self_and_ancestors.or(self.descendants)
        # self.class.where('traversal_ids[1] = ?', root_traversal_id)
      else
        super
      end
    end

    # Returns all the ancestors of the current namespaces.
    def ancestors
      return self.class.none unless parent_id

      if linear_group_traversal?
        self.class.where("traversal_ids <@ (?)", latest_traversal_ids_without_self.to_sql)
      else
        super
      end
    end

    # returns all ancestors upto but excluding the given namespace
    # when no namespace is given, all ancestors upto the top are returned
    def ancestors_upto(top = nil, hierarchy_order: nil)
      if linear_group_traversal?
        rel = rel.ancestors
        rel = rel.where.not("traversal_ids <@ (?)", latest_traversal_ids(top).to_sql) if top
        rel = rel.order(hierarchy_order_sql) if hierarchy_order
        rel
      else
        super
      end
    end

    def self_and_ancestors(hierarchy_order: nil)
      if linear_group_traversal?
        rel = self.class
        rel = rel.order(hierarchy_order_sql) if hierarchy_order
        rel.where("traversal_ids <@ (?)", latest_traversal_ids.to_sql)
      else
        super(hierarchy_order)
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
        self.class.where("traversal_ids @> (?)", latest_traversal_ids.to_sql)
      else
        super
      end
    end

    private

    def init_traversal_ids
      update_column(:traversal_ids, parent_traversal_ids + [id])
    end

    def sync_traversal_ids
      # This group and our descendents get new ancestors.
      old_traversal_ids = traversal_ids
      new_traversal_ids = parent_traversal_ids + [id]

      self_leaf_traversal_ids = "traversal_ids[#{old_traversal_ids.count}:array_length(traversal_ids, 1)]"
      self_and_descendants.update_all("traversal_ids = ARRAY#{new_traversal_ids} || #{self_leaf_traversal_ids}")

      # Sync this object to reflect DB updates.
      # Note that any related objects in memory may be stale.
      self.traversal_ids = new_traversal_ids
    end

    def parent_traversal_ids
      parent_id.present? ? parent.traversal_ids : []
    end

    ### SQL sub-select queries ###
    # traversal_ids are a cached value.
    #
    # The traversal_ids value in a loaded object can become stale when compared
    # to the database value. For example, if you load a hierarchy and then move
    # a group, any previously loaded descendent objects will have out of date
    # traversal_ids.
    #
    # To solve this problem, we query the database first with a sub-select for
    # the latest traversal_ids. The alternative which is cleaner though
    # contains nasty surprises, would be to use the potentially stale
    # traversal_ids object value and force `object#reload` calls as needed.

    def latest_root_traversal_ids(namespace = self)
      self.class.where(id: namespace.id).select('traversal_ids[1] as latest_traversal_ids')
    end

    def latest_traversal_ids(namespace = self)
      self.class.where(id: namespace.id).select('traversal_ids as latest_traversal_ids')
    end

    def latest_traversal_ids_without_self(namespace = self)
      self.class.where(id: namespace.id)
                .select('traversal_ids[1:(array_length(traversal_ids, 1)-1)] as latest_traversal_ids')
    end
    ### END SQL Sub-select queryies ###

    def hierarchy_order_sql(hierarchy_order)
      # We negate the depth because legacy code counted depth as from the
      # current node back up to the root node.
      Arel.sql("(-1 * array_length(traversal_ids, 1)) #{hierarchy_order}")
    end
  end
end
