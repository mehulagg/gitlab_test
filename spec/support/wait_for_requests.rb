require_relative './wait_for_ajax'
require_relative './wait_for_vue_resource'

module WaitForRequests
  extend self
  include WaitForAjax

  # This is inspired by http://www.salsify.com/blog/engineering/tearing-capybara-ajax-tests
  def wait_for_requests_complete
    Gitlab::Testing::RequestBlockerMiddleware.block_requests!
    wait_for('pending AJAX requests complete') do
      Gitlab::Testing::RequestBlockerMiddleware.num_active_requests.zero? &&
        finished_all_requests?
    end
  ensure
    Gitlab::Testing::RequestBlockerMiddleware.allow_requests!
  end
end

RSpec.configure do |config|
  config.after(:each, :js) do
    wait_for_requests_complete
  end
end
