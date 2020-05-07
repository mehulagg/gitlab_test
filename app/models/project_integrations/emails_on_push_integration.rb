# frozen_string_literal: true

class EmailsOnPushIntegration < Integration
  store_accessor :settings, :recipients, :branches_to_be_notified, :send_from_committer_email, :disable_diffs
end
