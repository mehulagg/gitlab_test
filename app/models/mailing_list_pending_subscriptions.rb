# frozen_string_literal: true

class MailingListPendingSubscriptions < ApplicationRecord
  belongs_to :mailing_list

  validates :user_email, presence: true, devise_email: true
end
