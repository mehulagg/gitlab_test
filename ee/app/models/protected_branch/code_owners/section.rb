# frozen_string_literal: true

class ProtectedBranch::CodeOwners::Section < ApplicationRecord
  self.table_name = :code_owners_sections

  belongs_to :file, class_name: 'ProtectedBranch::CodeOwners::File'

  has_many :entries, class_name: 'ProtectedBranch::CodeOwners::Entry'
end
