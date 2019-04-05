# frozen_string_literal: true

module EE
  module Gitlab
    module Workhorse
      extend ActiveSupport::Concern

      def service_request(service)
        {
          'Service' => {
            'Url' => service[:url],
            'Header' => service[:headers],
            'CAPem' => service[:ca_pem]
          }
        }
      end
    end
  end
end
