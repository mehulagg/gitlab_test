# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Build
        module Image
          extend ActiveSupport::Concern

          attr_reader :ports

          def initialize(image, job)
            super

            if image.is_a?(Hash) && job.pipeline.webide?
              @ports = image[:ports].to_a.map { |port| ::EE::Gitlab::Ci::Build::Port.new(port) }.select(&:valid?)
            end
          end
        end
      end
    end
  end
end
