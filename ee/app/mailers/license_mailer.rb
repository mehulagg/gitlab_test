# frozen_string_literal: true

class LicenseMailer < ApplicationMailer
  helper EmailsHelper

  layout 'mailer'

  def approaching_active_user_count_limit(recipients)
    return if License.current.nil?

    @license = License.current

    mail(
      bcc: recipients,
      subject: "Your subscription is nearing its user limit"
    )
  end
end
