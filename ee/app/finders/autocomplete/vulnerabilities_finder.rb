# frozen_string_literal: true

module Autocomplete
  class VulnerabilitiesFinder
    attr_reader :current_user, :vulnerable, :params

    # current_user - the User object of the user that wants to view the list of Vulnerabilities
    #
    # vulnerable - any object that has a #vulnerabilities method that returns a collection of vulnerabilitie
    # params - a Hash containing additional parameters to set
    #
    # The supported parameters are those supported by
    # `Security::VulnerabilitiesFinder`.
    def initialize(current_user, vulnerable, params = {})
      @current_user = current_user
      @vulnerable = vulnerable
      @params = params
    end

    def execute
      return [] unless vulnerable.feature_available?(:security_dashboard)

      ::Security::VulnerabilitiesFinder # rubocop: disable CodeReuse/Finder
        .new(vulnerable, params)
        .execute
        .visible_to_user_and_access_level(current_user, ::Gitlab::Access::DEVELOPER)
    end
  end
end
