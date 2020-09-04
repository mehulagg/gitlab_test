# frozen_string_literal: true

class ProtectedBranch::CodeOwners::Entry < ApplicationRecord
  self.table_name = :code_owners_entries

  belongs_to :section
end
