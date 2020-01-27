desc 'Run local Danger rules'
task :danger_local, [] => :environment do |_task, args|
  require 'gitlab_danger'
  require 'gitlab/popen'

  puts("#{GitlabDanger.local_warning_message}\n")

  # _status will _always_ be 0, regardless of failure or success :(
  output, _status = Gitlab::Popen.popen(%w{danger dry_run})

  # Run rubocop on files that have been changed against master
  files_to_lint, _ = Gitlab::Popen.popen %W(#{Gitlab.config.git.bin_path} diff --name-only master .)

  if files_to_lint.present?
    rubocop_params = %w(bundle exec rubocop --color).concat(files_to_lint.split(' '))
    rubocop_output, rubocop_status = Gitlab::Popen.popen(rubocop_params)

    if rubocop_status != 0
      output += "\n\n\e[1m------------------------ Rubocop Results ------------------------\e[0m\n\n"
      output += rubocop_output
    end
  end

  if output.empty?
    puts(GitlabDanger.success_message)
  else
    puts(output)
    exit(1)
  end
end
