# frozen_string_literal: true

module QA
  module Vendor
    module Jenkins
      module Page
        class Base
          include Capybara::DSL
          include Scenario::Actable

          attr_reader :path

          class << self
            attr_accessor :host
          end

          def visit!
            url = URI.join(Base.host, path).to_s
            Runtime::Logger.debug(%Q[Visiting #{self.class.name} at "#{url}"])

            page.visit url
          end
        end
      end
    end
  end
end
