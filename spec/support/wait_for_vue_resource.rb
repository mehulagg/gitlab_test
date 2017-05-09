module WaitForVueResource
  def finished_all_vue_resource_requests?
    return true unless javascript_test?

    page.evaluate_script('window.activeVueResources || 0').zero?
  end

  def javascript_test?
    Capybara.current_driver == Capybara.javascript_driver
  end
end
