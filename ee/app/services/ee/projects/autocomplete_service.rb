# frozen_string_literal: true
module EE
  module Projects
    module AutocompleteService
      def epics
        EpicsFinder
          .new(current_user, group_id: project.group&.id, state: 'opened')
          .execute.select([:iid, :title])
      end

      def vulnerabilities
        ::Security::VulnerabilitiesFinder
          .new(project)
          .execute
          .autocomplete_search(params[:search].to_s)
          .with_limit(5)
          .order_id_desc
          .select([:id, :title])
      end
    end
  end
end
