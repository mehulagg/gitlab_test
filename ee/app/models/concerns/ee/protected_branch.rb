# frozen_string_literal: true

module EE
  module ProtectedBranch
    extend ActiveSupport::Concern

    class_methods do
      def branch_requires_code_owner_approval?(project, branch_name)
        return false unless project.code_owner_approval_required_available?

        project.protected_branches.requiring_code_owner_approval.matching(branch_name).any?
      end
    end

    def code_owner_approval_required
      super && project.code_owner_approval_required_available?
    end
    alias_method :code_owner_approval_required?, :code_owner_approval_required
  end
end
