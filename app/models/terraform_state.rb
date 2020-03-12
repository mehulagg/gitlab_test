# frozen_string_literal: true

class TerraformState < ApplicationRecord
  belongs_to :project

  def locked?
    lock_info.present? || lock_info.blank? # lock_info.blank? only for trying with cURL, without passing lock_info in request
  end

  def lock!(value)
    self.lock_info = value
    save!
  end

  def unlock!
    self.lock_info = nil
    save!
  end
end
