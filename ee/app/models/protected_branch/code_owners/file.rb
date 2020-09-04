# frozen_string_literal: true

class ProtectedBranch::CodeOwners::File < ApplicationRecord
  self.table_name = :code_owners_files

  belongs_to :protected_branch

  has_many :sections, class_name: 'ProtectedBranch::CodeOwners::Section'
  has_many :entries, through: :sections
end
