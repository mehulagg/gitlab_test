# frozen_string_literal: true

module DastScanners
    class FindOrCreateService < BaseService
      PermissionsError = Class.new(StandardError)
  
      def execute!(name:)
        raise PermissionsError.new('Insufficient permissions') unless allowed?
  
        find_or_create_by!(name)
      end
  
      private
  
      def allowed?
        Ability.allowed?(current_user, :run_ondemand_dast_scan, project)
      end
  
      def find_or_create_by!(url)
        DastScanner.safe_find_or_create_by!(project: project, name: name)
      end
    end
  end
  