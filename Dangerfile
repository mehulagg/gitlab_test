# frozen_string_literal: true

require_relative 'lib/gitlab_danger'
require_relative 'lib/gitlab/danger/request_helper'

danger.import_plugin('danger/plugins/helper.rb')
danger.import_plugin('danger/plugins/roulette.rb')
danger.import_plugin('danger/plugins/changelog.rb')

# coding: utf-8
require "uri"
require "danger/helpers/comments_helper"
require "danger/helpers/comment"
require "danger/request_sources/support/get_ignored_violation"

module DangerGitlabMRFix
  def setup_danger_branches
    # we can use a GitLab specific feature here:
    base_branch = self.mr_json.source_branch
    base_commit = self.mr_json["diff_refs"]["base_sha"]
    head_branch = self.mr_json.target_branch
    head_commit = self.mr_json["diff_refs"]["head_sha"]

    # Next, we want to ensure that we have a version of the current branch at a known location
    scm.ensure_commitish_exists_on_branch! base_branch, base_commit
    self.scm.exec "branch #{EnvironmentManager.danger_base_branch} #{base_commit}"

    # OK, so we want to ensure that we have a known head branch, this will always represent
    # the head of the PR ( e.g. the most recent commit that will be merged. )
    scm.ensure_commitish_exists_on_branch! head_branch, head_commit
    self.scm.exec "branch #{EnvironmentManager.danger_head_branch} #{head_commit}"
  end
end

Danger::RequestSources::GitLab.prepend(DangerGitlabMRFix)

puts git.commits.map(&:sha)
puts helper.all_changed_files.inspect

# unless helper.release_automation?
#   GitlabDanger.new(helper.gitlab_helper).rule_names.each do |file|
#     danger.import_dangerfile(path: File.join('danger', file))
#   end
# end
