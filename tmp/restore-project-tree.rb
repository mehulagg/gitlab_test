shared_class = Struct.new(:export_path) do
  def error(message)
    raise message
  end
end

load 'tmp/ar_bulk_insert.rb'

ActiveRecord::Base.logger = Logger.new(STDOUT)
RequestStore.begin!
RequestStore.clear!

project = Project.find(38)
project.issues.all.delete_all
project.merge_requests.all.delete_all
project.ci_pipelines.delete_all

# shared = shared_class.new('./exports/single-relation')
shared = shared_class.new('./tmp/exports/gitlabhq')

result = Benchmark.measure do
  Gitlab::ImportExport::ProjectTreeRestorer.new(
    user: User.first,
    shared: shared,
    project: project
  ).restore
end

pp result
