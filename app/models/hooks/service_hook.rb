# frozen_string_literal: true

class ServiceHook < WebHook
  belongs_to :service
  validates :service, presence: true

  # rubocop: disable CodeReuse/ServiceClass
  def execute(data, hook_name = 'service_hook')
    WebHookService.new(self, data, hook_name).execute
  end
  # rubocop: enable CodeReuse/ServiceClass

  def log_execution(attributes)
    return unless Feature.enabled?(:service_hook_logging, service.project)

    super(attributes)
  end
end
