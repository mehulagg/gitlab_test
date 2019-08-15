# frozen_string_literal: true
class Packages::PackageTag < ApplicationRecord
  belongs_to :package
end
