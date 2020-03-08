require "bundler/setup"
# require "sidekiq/testing"
require "gitlab/migration_helpers"

require File.join(__dir__, "support", "shared_examples.rb")

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def database_config
    config_file = ENV.fetch("GITLAB_MIGRATION_HELPERS_TEST_DATABASE_CONFIG",
                                      File.join(__dir__, "support", "database.yml"))

    YAML.load(ERB.new(File.read(config_file)).result)
  end

  ActiveRecord::Base.configurations = database_config
  ActiveRecord::Base.establish_connection(database_config["test"])
end
