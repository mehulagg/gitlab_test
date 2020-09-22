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
          if Gitlab::Geo.primary?
            if Gitlab::Geo.license_allows?
              return "License supported, Enable Geo to use"
            else
              return "Geo disabled, but would not be supported on current license"
            end
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
