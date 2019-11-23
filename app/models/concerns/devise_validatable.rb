# frozen_string_literal: true

# Validations in this module are copied over from
# https://github.com/plataformatec/devise/blob/v4.7.1/lib/devise/models/validatable.rb

# TODO: Remove this concern and go back to using Devise's in built Validatable module as soon as
# https://github.com/plataformatec/devise/pull/5166 is merged.
module DeviseValidatable
  extend ActiveSupport::Concern

  # rubocop: disable Rails/Validation
  included do
    validates_presence_of   :email, if: :email_required?
    validates_uniqueness_of :email, allow_blank: true, case_sensitive: true, if: :will_save_change_to_email?
    validates_format_of     :email, with: Devise.email_regexp, allow_blank: true, if: :will_save_change_to_email?

    validates_presence_of     :password, if: :password_required?
    validates_confirmation_of :password, if: :password_required?

    # This is the only validation that differs from the validations already present in Devise's Validatable module.
    # We need this validation so that we can support dynamic password length without a GitLab restart.
    validates_length_of :password, maximum: proc { password_length.max }, minimum: proc { password_length.min }, allow_blank: true
  end
  # rubocop: enable Rails/Validation

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def email_required?
    true
  end
end
