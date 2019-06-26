# frozen_string_literal: true

module DesignManagement
  class DeleteDesignsService < ::BaseService
    def initialize(project, user, params = {})
      super

      @issue = params.fetch(:issue)
      @designs = params.fetch(:designs)
    end

    def execute
      return error('Forbidden!') unless can_delete_designs?

      delete_designs!

      success({})
    rescue Gitlab::Git::BaseError, ActiveRecord::RecordInvalid => e
      error(e.message)
    end

    private

    attr_reader :designs, :issue
    alias_method :removed_designs, :designs

    def can_delete_designs?
      Ability.allowed?(current_user, :destroy_design, issue)
    end

    def delete_designs!
      return if designs.empty?

      commit_sha = remove_designs!
      DesignManagement::Version.create_deleted_in!(removed_designs, commit_sha)
    end

    def remove_designs!
      repository.create_if_not_exists
      repository_actions = designs.map do |design|
        {
          action: :delete,
          file_path: design.full_path
        }
      end
      repository.multi_action(current_user,
                              branch_name: target_branch,
                              message: commit_message,
                              actions: repository_actions)
    end

    def collection
      issue.design_collection
    end

    def repository
      collection.repository
    end

    def project
      issue.project
    end

    def target_branch
      repository.root_ref || "master"
    end

    def commit_message
      <<~MSG
      Removed #{removed_designs.size} #{'designs'.pluralize(removed_designs.size)}

      #{formatted_file_list}
      MSG
    end

    def formatted_file_list
      removed_designs.map { |design| "- #{design.full_path}" }.join("\n")
    end
  end
end
