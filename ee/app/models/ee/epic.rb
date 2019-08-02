# frozen_string_literal: true

module EE
  module Epic
    extend ActiveSupport::Concern

    prepended do
      include AtomicInternalId
      include IidRoutes
      include ::Issuable
      include ::Noteable
      include Referable
      include Awardable
      include LabelEventable
      include RelativePositioning
      include ::Gitlab::Utils::StrongMemoize

      enum state: { opened: 1, closed: 2 }

      belongs_to :closed_by, class_name: 'User'

      def reopen
        return if opened?

        update(state: :opened, closed_at: nil, closed_by: nil)
      end

      def close
        return if closed?

        update(state: :closed, closed_at: Time.zone.now)
      end

      belongs_to :assignee, class_name: "User"
      belongs_to :group
      belongs_to :start_date_sourcing_milestone, class_name: 'Milestone'
      belongs_to :due_date_sourcing_milestone, class_name: 'Milestone'
      belongs_to :start_date_sourcing_epic, class_name: 'Epic'
      belongs_to :due_date_sourcing_epic, class_name: 'Epic'
      belongs_to :parent, class_name: "Epic"
      has_many :children, class_name: "Epic", foreign_key: :parent_id

      has_internal_id :iid, scope: :group, init: ->(s) { s&.group&.epics&.maximum(:iid) }

      has_many :epic_issues
      has_many :issues, through: :epic_issues

      validates :group, presence: true
      validate :validate_parent, on: :create

      alias_attribute :parent_ids, :parent_id

      scope :in_parents, -> (parent_ids) { where(parent_id: parent_ids) }
      scope :inc_group, -> { includes(:group) }

      scope :order_start_or_end_date_asc, -> do
        reorder("COALESCE(start_date, end_date) ASC NULLS FIRST")
      end

      scope :order_start_date_asc, -> do
        reorder(::Gitlab::Database.nulls_last_order('start_date'), 'id DESC')
      end

      scope :order_end_date_asc, -> do
        reorder(::Gitlab::Database.nulls_last_order('end_date'), 'id DESC')
      end

      scope :order_end_date_desc, -> do
        reorder(::Gitlab::Database.nulls_last_order('end_date', 'DESC'), 'id DESC')
      end

      scope :order_start_date_desc, -> do
        reorder(::Gitlab::Database.nulls_last_order('start_date', 'DESC'), 'id DESC')
      end

      scope :order_relative_position, -> do
        reorder('relative_position ASC', 'id DESC')
      end

      scope :with_api_entity_associations, -> { preload(:author, :labels, :group) }

      MAX_HIERARCHY_DEPTH = 5

      def etag_caching_enabled?
        true
      end
    end

    class_methods do
      # We support internal references (&epic_id) and cross-references (group.full_path&epic_id)
      #
      # Escaped versions with `&amp;` will be extracted too
      #
      # The parent of epic is group instead of project and therefore we have to define new patterns
      def reference_pattern
        @reference_pattern ||= begin
          combined_prefix = Regexp.union(Regexp.escape(reference_prefix), Regexp.escape(reference_prefix_escaped))
          group_regexp = %r{
            (?<!\w)
            (?<group>#{::Gitlab::PathRegex::FULL_NAMESPACE_FORMAT_REGEX})
          }x
          %r{
            (#{group_regexp})?
            (?:#{combined_prefix})(?<epic>\d+)
          }x
        end
      end

      def reference_valid?(reference)
        reference.to_i > 0 && reference.to_i <= ::Gitlab::Database::MAX_INT_VALUE
      end

      def link_reference_pattern
        %r{
          (?<url>
            #{Regexp.escape(::Gitlab.config.gitlab.url)}
            \/groups\/(?<group>#{::Gitlab::PathRegex::FULL_NAMESPACE_FORMAT_REGEX})
            \/-\/epics
            \/(?<epic>\d+)
            (?<path>
              (\/[a-z0-9_=-]+)*
            )?
            (?<query>
              \?[a-z0-9_=-]+
              (&[a-z0-9_=-]+)*
            )?
            (?<anchor>\#[a-z0-9_-]+)?
          )
        }x
      end

      def order_by(method)
        case method.to_s
        when 'start_or_end_date' then order_start_or_end_date_asc
        when 'start_date_asc' then order_start_date_asc
        when 'start_date_desc' then order_start_date_desc
        when 'end_date_asc' then order_end_date_asc
        when 'end_date_desc' then order_end_date_desc
        when 'relative_position' then order_relative_position
        else
          super
        end
      end

      def parent_class
        ::Group
      end

      def relative_positioning_query_base(epic)
        in_parents(epic.parent_ids)
      end

      def relative_positioning_parent_column
        :parent_id
      end

      # Return the deepest relation level for an epic.
      # Example 1:
      # epic1 - parent: nil
      # epic2 - parent: epic1
      # epic3 - parent: epic 2
      # Returns: 3
      # ------------
      # Example 2:
      # epic1 - parent: nil
      # epic2 - parent: epic1
      # Returns: 2
      def deepest_relationship_level
        ::Gitlab::ObjectHierarchy.new(self.where(parent_id: nil)).max_descendants_depth
      end

      def update_sourcing_date(epics, source)
        # FIXME - add also end_date
        update_attrs = if source.is_a?(::Milestone)
                         { start_date_sourcing_milestone_id: source&.id,
                           start_date_sourcing_epic_id: nil,
                           start_date: source&.start_date }
                       else
                         { start_date_sourcing_milestone_id: nil,
                           start_date_sourcing_epic_id: source&.id,
                           start_date: source&.start_date }
                       end

        ::Epic.where(id: epics).update_all(update_attrs)
      end
    end

    def assignees
      Array(assignee)
    end

    def project
      nil
    end

    def supports_weight?
      false
    end

    def upcoming?
      start_date&.future?
    end

    def expired?
      end_date&.past?
    end

    def elapsed_days
      return 0 if start_date.nil? || start_date.future?

      (Date.today - start_date).to_i
    end

    # Needed to use EntityDateHelper#remaining_days_in_words
    alias_attribute(:due_date, :end_date)

    # TODO - schedule this asynchronously
    def update_start_and_due_dates(descendant)
      if !start_date_is_fixed?
        update_sourcing_start_date_in_hierarchy(descendant)
      end

      if !due_date_is_fixed? # FIXME - milestone uses due date
        update_sourcing_end_date_in_hierarchy(descendant)
      end
    end

    def update_sourcing_start_date_in_hierarchy(descendant)
      earliest = descendant
      inheriting_epics(descendant).each_with_index do |epic, idx|
        # new date is still earlier than existing start_dates
        # so we can update sourcing_date for all ascendants which
        # inherit from the this epic
        if epic.earliest_start_date?(earliest)
          self.class.update_sourcing_date(epics[idx..], earliest)
          break
        end

        # if new_min is earlier than earliest, we have to update only this
        # epic, and recheck on its ascendants
        earliest = min_sourcing
        self.class.update_sourcing_date([epic], earliest)
      end
    end

    def update_sourcing_end_date_in_hierarchy(descendant)
      latest = descendant
      inheriting_epics(descendant).each_with_index do |epic, idx|
        if epic.latest_due_date?(latest)
          self.class.update_sourcing_date(epics[idx..], latest)
          break
        end

        latest = max_sourcing
        self.class.update_sourcing_date([epic], latest)
      end
    end

    def inheriting_epics(descendant)
      # FIXME -cleanup
      # FIXME - add end_date too
      @inheriting_epics ||= {}
      @inheriting_epics[descendant] ||=
        begin
          epics = []
          base_and_ancestors(order: :desc).each do |epic|
            break if epic.start_date_fixed?
            break if descendant&.start_date && epic.start_date && epic.start_date >= descendant.start_date
            # TODO - break if descendant's date is nil and epic's date is not inheriting from descendant

            epics << epic
          end

          epics
        end
    end

    def earliest_start_date?(changed_resource)
      return false unless changed_resource&.start_date
      # new start_date is earlier than the current start_date
      return true if start_date.nil? || changed_resource.start_date < start_date

      # if the new date (changed_resource) is still earlier than any other
      # existing minimal start_date, then we can still update start_date for
      # all descendants
      changed_resource.start_date <= min_sourcing.start_date
    end

    def latest_due_date?(changed_resource)
      return false unless changed_resource&.due_date
      # new start_date is earlier than the current start_date
      return true if due_date.nil? || changed_resource.due_date > due_date

      if changed_resource.due_date > due_date
        # new start_date is earlier than the current start_date
        return true
      end

      changed_resource.due_date >= max_sourcing.start_date
    end

    def min_sourcing
      strong_memoize(:min_start_date) do
        [min_milestone_start_date, min_child_epics_start_date].compact.min_by(&:the_date)
      end
    end

    def max_sourcing
      strong_memoize(:max_due_date) do
        [max_milestone_due_date, max_child_epics_due_date].compact.max_by(&:the_date)
      end
    end

    def start_date_from_milestones
      start_date_is_fixed? ? start_date_sourcing_milestone&.start_date : start_date
    end

    def due_date_from_milestones
      due_date_is_fixed? ? due_date_sourcing_milestone&.due_date : due_date
    end

    def to_reference(from = nil, full: false)
      reference = "#{self.class.reference_prefix}#{iid}"

      return reference unless (cross_reference?(from) && !group.projects.include?(from)) || full

      "#{group.full_path}#{reference}"
    end

    def cross_reference?(from)
      from && from != group
    end

    def ancestors
      return self.class.none unless parent_id

      hierarchy.ancestors(hierarchy_order: :asc)
    end

    def max_hierarchy_depth_achieved?
      base_and_ancestors.count >= MAX_HIERARCHY_DEPTH
    end

    def descendants
      hierarchy.descendants
    end

    def has_ancestor?(epic)
      ancestors.exists?(epic.id)
    end

    def has_children?
      children.any?
    end

    def has_issues?
      issues.any?
    end

    def child?(id)
      children.where(id: id).exists?
    end

    def hierarchy
      ::Gitlab::ObjectHierarchy.new(self.class.where(id: id))
    end

    # we don't support project epics for epics yet, planned in the future #4019
    def update_project_counter_caches
    end

    # we call this when creating a new epic (Epics::CreateService) or linking an existing one (EpicLinks::CreateService)
    # when called from EpicLinks::CreateService we pass
    #   parent_epic - because we don't have parent attribute set on epic
    #   parent_group_descendants - we have preloaded them in the service and we want to prevent performance problems
    #     when linking a lot of issues
    def valid_parent?(parent_epic: nil, parent_group_descendants: nil)
      parent_epic ||= parent

      return true unless parent_epic

      parent_group_descendants ||= parent_epic.group.self_and_descendants

      return false if self == parent_epic
      return false if level_depth_exceeded?(parent_epic)
      return false if parent_epic.has_ancestor?(self)
      return false if parent_epic.children.to_a.include?(self)

      parent_group_descendants.include?(group)
    end

    def issues_readable_by(current_user, preload: nil)
      related_issues = ::Issue.select('issues.*, epic_issues.id as epic_issue_id, epic_issues.relative_position')
        .joins(:epic_issue)
        .preload(preload)
        .where("epic_issues.epic_id = #{id}")
        .order('epic_issues.relative_position, epic_issues.id')

      Ability.issues_readable_by_user(related_issues, current_user)
    end

    def mentionable_params
      { group: group, label_url_method: :group_epics_url }
    end

    def discussions_rendered_on_frontend?
      true
    end

    def banzai_render_context(field)
      super.merge(label_url_method: :group_epics_url)
    end

    def validate_parent
      return true if valid_parent?

      errors.add :parent, 'The parent is not valid'
    end
    private :validate_parent

    def level_depth_exceeded?(parent_epic)
      hierarchy.max_descendants_depth.to_i + parent_epic.ancestors.count >= MAX_HIERARCHY_DEPTH
    end
    private :level_depth_exceeded?

    def base_and_ancestors(order: :asc)
      return self.class.none unless parent_id

      hierarchy.base_and_ancestors(hierarchy_order: order)
    end
    private :base_and_ancestors

    private

    def source_milestones_query
      ::Milestone.joins(issues: :epic_issue).where("epic_issues.epic_id = ?", self.id)
    end

    def min_milestone_start_date
      milestone = source_milestones_query
        .where.not(start_date: nil)
        .select("milestones.start_date AS start_date, milestones.id as id")
        .order("start_date asc").first

      milestone&.start_date.nil? ? nil : milestone
    end

    def max_milestone_due_date
      milestone = source_milestones_query
        .where.not(due_date: nil)
        .select("milestones.due_date AS due_date, milestones.id as source_id")
        .order("due_date desc").first

      milestone&.due_date.nil? ? nil : milestone
    end

    def min_child_epics_start_date
      epic = ::Epic.where(parent_id: self.id)
        .where.not(start_date: nil)
        .select("epics.start_date AS start_date, epics.id as id")
        .order("start_date asc").first

      epic&.start_date.nil? ? nil : epic
    end

    def max_child_epics_due_date
      epic = ::Epic.where(parent_id: self.id)
        .where.not(end_date: nil)
        .select("epics.end_date AS due_date, epics.id as source_id")
        .order("due_date desc").first

      epic&.due_date.nil? ? nil : epic
    end
  end
end
