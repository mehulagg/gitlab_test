# frozen_string_literal: true

module Labels
  class BatchFindOrCreateService
    def initialize(current_user, parent)
      @current_user = current_user
      @parent = parent

      # Pre-load labels on init
      available_labels
    end

    def execute(label)
      find_or_create_label(label)
    end

    private

    attr_reader :current_user, :parent, :params

    def available_labels
      @available_labels ||= LabelsFinder.new(
        current_user,
        "#{parent_type}_id".to_sym => parent.id,
        include_ancestor_groups: true,
        only_group_labels: parent_is_group?
      ).execute(skip_authorization: false).all
    end

    def find_or_create_label(label)
      new_label = available_labels.find { |avail_label| avail_label.title = label.title }

      if new_label.nil? && Ability.allowed?(current_user, :admin_label, parent)
        create_params = label.attributes.slice("title", "description", "color")
        new_label = Labels::CreateService.new(create_params).execute(parent_type.to_sym => parent)
      end

      new_label
    end

    def parent_type
      parent.model_name.param_key
    end

    def parent_is_group?
      parent_type == "group"
    end
  end
end
