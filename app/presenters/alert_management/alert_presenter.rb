# frozen_string_literal: true

module AlertManagement
  class AlertPresenter
    def self.new(alert, **attributes)
      presenter_class = alert.prometheus? ? PrometheusAlertPresenter : GenericAlertPresenter

      presenter_class.new(alert, **attributes)
    end
  end
end
