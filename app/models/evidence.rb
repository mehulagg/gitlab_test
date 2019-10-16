# frozen_string_literal: true

class Evidence < ApplicationRecord
  belongs_to :release

  default_scope { order(created_at: :asc) }

  def sha
    return unless summary

    Gitlab::CryptoHelper.sha256(summary)
  end

  def milestones
    @milestones ||= release.milestones.includes(:issues)
  end
end
