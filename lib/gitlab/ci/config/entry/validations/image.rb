# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        module Validations
          module Image
            extend ActiveSupport::Concern

            included do
              validates :config, hash_or_string: true

              validates :name, type: String, presence: true
              validates :entrypoint, array_of_strings: true, allow_nil: true
            end
          end
        end
      end
    end
  end
end
