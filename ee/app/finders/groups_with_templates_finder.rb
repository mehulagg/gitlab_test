# frozen_string_literal: true

class GroupsWithTemplatesFinder
  # We need to provide grace period for users who are now using group_project_template
  # feature in free groups.
  CUT_OFF_DATE = Date.parse('2019/05/22') + 3.months

  def initialize(group_id = nil, base_groups: nil)
    @base_groups = base_groups || Group.all
    @group_id = group_id
  end

  def execute
    if ::Gitlab::CurrentSettings.should_check_namespace_plan? && Time.zone.now > CUT_OFF_DATE
      groups = extended_group_search
      simple_group_search(groups)
    else
      simple_group_search(base_groups)
    end
  end

  private

  attr_reader :base_groups, :group_id

  def extended_group_search
    groups = base_groups.with_feature_available_in_plan(:group_project_templates)

    Gitlab::ObjectHierarchy.new(groups).base_and_descendants
  end

  def simple_group_search(groups)
    groups = group_id ? groups.find_by(id: group_id)&.self_and_ancestors : groups # rubocop: disable CodeReuse/ActiveRecord
    return Group.none unless groups

    groups.with_project_templates
  end
end
