# frozen_string_literal: true

module Services
  module DataFields
    extend ActiveSupport::Concern

    included do
      belongs_to :service

      delegate :activated?, to: :service, allow_nil: true

      validates :service, presence: true
    end

    class_methods do
      def encryption_options
        Service::ENCRYPTION_OPTIONS.dup
      end
    end
  end
end
