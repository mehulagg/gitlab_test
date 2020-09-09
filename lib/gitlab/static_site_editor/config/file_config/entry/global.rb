# frozen_string_literal: true

module Gitlab
  module StaticSiteEditor
    module Config
      class FileConfig
        module Entry
          ##
          # This class represents a global entry - root Entry for entire
          # GitLab StaticSiteEditor Configuration file.
          #
          class Global < ::Gitlab::Config::Entry::Node
            include ::Gitlab::Config::Entry::Configurable
            include ::Gitlab::Config::Entry::Attributable

            validations do
              allowed_keys = %i[static_site_generator]
              validates :config, allowed_keys: allowed_keys
            end

            entry :static_site_generator, Entry::StaticSiteGenerator,
                  description: 'Configuration of the Static Site Editor static site generator.'

            attributes :static_site_generator
          end
        end
      end
    end
  end
end
