namespace :gitlab do
  desc "GitLab | Generate Sample Prometheus Data"
  task :generate_sample_prometheus_data, [:environment_id] => :gitlab_environment do |_, args|
    environment = Environment.find(args[:environment_id])
    metrics = PrometheusMetric.where(project_id: [environment.project.id, nil])
    query_variables = Gitlab::Prometheus::QueryVariables.call(environment)

    sample_metrics_directory_name = Metrics::SampleMetricsService::DIRECTORY
    Dir.mkdir(sample_metrics_directory_name) unless File.exist?(sample_metrics_directory_name)

    metrics.each do |metric|
      next unless metric.identifier

      query = metric.query % query_variables
      result = {}
      query_ranges.each do |query_range|
        result[query_range] = environment.prometheus_adapter.prometheus_client.query_range(query, start: query_range.minutes.ago)
      end
      File.write("#{sample_metrics_directory_name}/#{metric.identifier}.yml", result.to_yaml)
    end
  end
end

def query_ranges
  [30, 180, 480, 1440, 4320, 10080]
end
