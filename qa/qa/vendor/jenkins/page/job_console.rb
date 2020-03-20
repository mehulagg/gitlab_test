# frozen_string_literal: true

require 'capybara/dsl'

module QA
  module Vendor
    module Jenkins
      module Page
        class JobConsole < Page::Base
          attr_accessor :job_name

          def path
            "/job/#{@job_name}/console"
          end

          def failed_status_update?
            page.has_text?('Failed to update Gitlab commit status')
          end
        end
      end
    end
  end
end
