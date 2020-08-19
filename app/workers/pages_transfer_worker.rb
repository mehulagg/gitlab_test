# frozen_string_literal: true

class PagesTransferWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  TransferFailedError = Class.new(StandardError)

  feature_category :pages
  loggable_arguments 0, 1

  def perform(method, args)
    return unless Gitlab::PagesTransfer::Async::METHODS.include?(method)

    result = Gitlab::PagesTransfer.new.public_send(method, *args) # rubocop:disable GitlabSecurity/PublicSend

    # If the transfer failed, we want to allow Sidekiq to retry
    raise TransferFailedError unless result
  end
end
