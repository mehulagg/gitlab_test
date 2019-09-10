# frozen_string_literal: true

# Requires ENV['GITLAB_ADDRESS'] to defined before calling rake task
namespace :zero_downtime do
  desc 'Runs login e2e test'
  RSpec::Core::RakeTask.new(:login_spec) do |t|
    ENV['zero_downtime_rake'] = 'true'
    ENV['QA_DEBUG'] = 'true'
    t.pattern = ["qa/qa/specs/features/browser_ui/1_manage/login/log_in_spec.rb"]
    t.rspec_opts = "--format documentation"
  end
end
