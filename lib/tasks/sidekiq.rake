namespace :sidekiq do
  desc "GitLab | Stop sidekiq"
  task :stop do
    system(*%w(bin/background_jobs stop))
  end

  desc "GitLab | Start sidekiq as a background process (logs to log/sidekiq.log)"
  task :start do
    system(*%w(bin/background_jobs start_background))
  end

  desc "GitLab | Start sidekiq in the foreround (logs to STDOUT)"
  task :start_foreground do
    system(*%w(bin/background_jobs start))
  end

  desc "GitLab | Start sidekiq in the foreground (logs to log/sidekiq.log)"
  task :start_foreground_silent do
    system(*%w(bin/background_jobs start_silent))
  end

  task launchd: :start_foreground_silent

  desc 'GitLab | Restart sidekiq'
  task :restart do
    system(*%w(bin/background_jobs restart))
  end
end
