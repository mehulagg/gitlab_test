# frozen_string_literal: true

module EE
  module DiffNote
    extend ::Gitlab::Utils::Override
    extend ActiveSupport::Concern

    class_methods do
      def noteable_types
        super + %w(DesignManagement::Design)
      end
    end

    override :supported?
    def supported?
      for_design? || super
    end

    override :created_at_diff?
    def created_at_diff?(diff_refs)
      return false if for_design?

      super
    end

    # Disallow notes on Designs from being resolvable.
    # https://gitlab.com/gitlab-org/gitlab-ce/issues/64148
    def resolvable?
      for_design? ? false : super
    end

    # diffs are currently not suported for designs
    # this needs to be decoupled from the `Project#repository`
    # override :latest_diff_file
    # def latest_diff_file
    #   return super unless for_design?
    # end

    # override :diff_file
    # def diff_file
    #   return super unless for_design?
    # end
  end
end
