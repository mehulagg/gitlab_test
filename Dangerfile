# frozen_string_literal: true

require 'gitlab-dangerfiles'

spec = Gem::Specification.find_by_name('gitlab-dangerfiles')
danger.import_dangerfile(path: File.join(spec.gem_dir, 'lib', 'gitlab'))

return if helper.release_automation?

helper.rule_names.each do |rule|
  danger.import_dangerfile(path: File.join(spec.gem_dir, 'lib', 'gitlab', 'dangerfiles', rule))
end

anything_to_post = status_report.values.any? { |data| data.any? }

if helper.ci? && anything_to_post
  markdown("**If needed, you can retry the [`danger-review` job](#{ENV['CI_JOB_URL']}) that generated this comment.**")
end
