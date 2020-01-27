# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a configuration of Vault secrets.
        #
        class Secrets < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Validatable

          # TODO
          validations do
            validates :config, type: Hash
          end
        end
      end
    end
  end
end
