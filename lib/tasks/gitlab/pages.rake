namespace :gitlab do
  namespace :pages do
    desc "GitLab | Install or upgrade GitLab-Pages"
    task :install, [:dir, :repo] => :gitlab_environment do |t, args|
      warn_user_is_not_gitlab

      unless args.dir.present?
        abort %(Please specify the directory where you want to install gitlab-pages:\n  rake "gitlab:pages:install[/home/git/gitlab-pages]")
      end

      args.with_defaults(repo: 'https://gitlab.com/gitlab-org/gitlab-pages.git')

      version = Gitlab::Pages::VERSION

      checkout_or_clone_version(version: version, repo: args.repo, target_dir: args.dir)

      _, status = Gitlab::Popen.popen(%w[which gmake])
      command = status.zero? ? 'gmake' : 'make'

      Dir.chdir(args.dir) do
        run_command!([command])
      end
    end
  end
end
