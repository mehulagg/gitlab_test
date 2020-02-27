# frozen_string_literal: true

require_relative 'lib/gitlab_danger'
require_relative 'lib/gitlab/danger/request_helper'

danger.import_plugin('danger/plugins/helper.rb')
danger.import_plugin('danger/plugins/roulette.rb')
danger.import_plugin('danger/plugins/changelog.rb')

module Danger
  class EnvironmentManager
    def clean_up
      # Dont' clean up Danger branches
    end
  end
end

puts git.commits.inspect
puts git.modified_files.inspect
puts git.added_files.inspect
puts helper.all_changed_files.inspect
puts git.instance_variable_get(:@git).log.inspect
puts git.instance_variable_get(:@git).diff.inspect

# unless helper.release_automation?
#   GitlabDanger.new(helper.gitlab_helper).rule_names.each do |file|
#     danger.import_dangerfile(path: File.join('danger', file))
#   end
# end
