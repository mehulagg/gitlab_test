# frozen_string_literal: true

class ServiceHook < WebHook
  belongs_to :service
  validates :service, presence: true

  # rubocop: disable CodeReuse/ServiceClass
  def execute(data, hook_name = 'service_hook')
    WebHookService.new(self, data, hook_name).execute
  end
  # rubocop: enable CodeReuse/ServiceClass

  def log_execution(params)
    return log_error(params) if params[:error_message]

    log_info(params)
  end

  private

  def log_error(options)
    message = log_message
    message[:message] = options.delete(:error_message)
    Gitlab::ProjectServiceLogger.error(message.merge(options))
  end

  def log_info(options)
    Gitlab::ProjectServiceLogger.info(log_message.merge(options))
  end

  def log_message
    {
      service_class: service.class.name,
      project_id: project.id,
      project_path: project.full_path,
      message: nil
    }
  end

  def project
    @project ||= service.project
  end
end
