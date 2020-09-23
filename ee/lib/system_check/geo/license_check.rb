# frozen_string_literal: true

module SystemCheck
  module Geo
    class LicenseCheck < SystemCheck::BaseCheck
      set_name 'GitLab Geo is available'

      def check?
        if Gitlab::Geo.enabled?
          return Gitlab::Geo.primary? ? Gitlab::Geo.license_allows? : true
        end

        true
      end

      def self.check_pass
        if Gitlab::Geo.enabled?
          return "License only required on a primary site" unless Gitlab::Geo.primary?
        else
          if Gitlab::Geo.license_allows?
            return "License supports Geo, but Geo is not enabled"
          else
            return "License does not support Geo, and Geo is not enabled"
          end
        end

        ""
      end

      def show_error
        try_fixing_it(
          'Upload a new license that includes the GitLab Geo feature'
        )

        for_more_information('https://about.gitlab.com/features/gitlab-geo/')
      end
    end
  end
end
