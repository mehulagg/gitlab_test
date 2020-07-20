# frozen_string_literal: true

class DastScannerProfile < ApplicationRecord
  belongs_to :project
end
