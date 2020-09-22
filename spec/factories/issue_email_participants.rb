# frozen_string_literal: true

FactoryBot.define do
  factory :issue_email_participant do
    issue
    email
  end
end
