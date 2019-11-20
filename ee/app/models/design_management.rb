# frozen_string_literal: true

module DesignManagement
  # TODO these might not be in the right place
  IMAGE_SIZE_ORIGINAL = 'original'
  IMAGE_SIZES = [IMAGE_SIZE_ORIGINAL, 'small'].freeze

  def self.designs_directory
    'designs'
  end

  def self.table_name_prefix
    'design_management_'
  end
end
