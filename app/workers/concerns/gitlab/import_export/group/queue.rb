# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Queue
        extend ActiveSupport::Concern

        included do
          queue_namespace :group_import_export
        end
      end
    end
  end
end
