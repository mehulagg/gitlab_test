# frozen_string_literal: true
#
# A Namespace::TraversalHierarchy is the collection of namespaces that descend
# from a root Namespace.
#
# This class provides operations to be performed on the hierarchy itself,
# rather than individual namespaces.
#
# Methods for synchronizing traversal_ids attribute to correct state.
# We use recursive methods to determine the correct state so we don't have to
# depend on the integrity of the traversal_ids attribute values.
#
class Namespace
  class TraversalHierarchy

    attr_accessor :root

    def self.for_namespace(namespace)
      @root = recursive_root_ancestor(namespace)
    end

    def initialize(root)
      @root = root
    end

    # Update all traversal_ids in the current namespace hierarchy.
    def sync_traversal_ids!
      # An issue in Rails since 2013 prevents this kind of join based update in
      # ActiveRecord. https://github.com/rails/rails/issues/13496
      # Ideally it would be:
      #   `incorrect_traversal_ids.update_all('traversal_ids = cte.traversal_ids')`
      sql =<<-EOD
        UPDATE namespaces
        SET traversal_ids = cte.traversal_ids
        FROM (#{recursive_traversal_ids}) as cte
        WHERE namespaces.id = cte.id
      EOD
      Namespace.connection.exec_query(sql)
    end

    # Identify all incorrect traversal_ids in the current namespace hierarchy.
    def incorrect_traversal_ids
      Namespace \
        .joins("INNER JOIN (#{recursive_traversal_ids}) as cte ON namespaces.id = cte.id")
        .where('namespaces.traversal_ids <> cte.traversal_ids')
    end

    private

    # Determine traversal_ids for the namespace hierarchy using recursive methods.
    # Generate a collection of [id, traversal_ids] rows.
    #
    # Note that the traversal_ids represent a calculated traversal path for the
    # namespace and not the value stored within the traversal_ids attribute.
    def recursive_traversal_ids
      recursive_cte = <<-EOD
        WITH RECURSIVE cte(id, traversal_ids, cycle) AS (
          VALUES(#{@root.id}, ARRAY[#{@root.id}], false)
        UNION ALL
          SELECT n.id, cte.traversal_ids || n.id, n.id = ANY(cte.traversal_ids)
          FROM namespaces n, cte
          WHERE n.parent_id = cte.id AND NOT cycle
        )
        SELECT id, traversal_ids FROM cte
      EOD
    end

    def self.recursive_root_ancestor(namespace)
      Gitlab::ObjectHierarchy
        .new(Namespace.where(id: namespace))
        .base_and_ancestors
        .reorder(nil)
        .find_by(parent_id: nil)
    end

  end
end
