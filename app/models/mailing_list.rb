# frozen_string_literal: true

class MailingList < ApplicationRecord
  include FeatureGate

  validates :email, presence: true

  belongs_to :project

  has_many :mailing_list_subscriptions
  has_many :mailing_list_pending_subscriptions
end
