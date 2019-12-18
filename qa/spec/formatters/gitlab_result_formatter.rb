class GitlabResultFormatter
  RSpec::Core::Formatters.register self, :example_passed, :example_failed

  def initialize(out)
    @out = out
  end

  def example_finished(notification)
    example = notification.example

    QA::Runtime::Logger.debug("\nLogging result: #{example.file_path}\n")

    result = {
      name: example.file_path.gsub(/^\.\//, ''),
      result: example.execution_result.status,
      field1: example.exception,
      field2: example.execution_result.started_at,
      field3: example.execution_result.finished_at,
      field4: "#{example.execution_result.run_time}s"
    }

    req = QA::Runtime::API::Request.new(QA::Runtime::API::Client.new(:gitlab),
                                  "#{ENV['CI_JOB_URL']}/results")
    RestClient::Request.execute(
      method: :post,
      url: req.url,
      payload: result,
      verify_ssl: false)
  rescue RestClient::ExceptionWithResponse => e
    raise e unless e.respond_to?(:response) && e.response

    e.response
  end

  alias_method :example_passed, :example_finished
  alias_method :example_failed, :example_finished
end
