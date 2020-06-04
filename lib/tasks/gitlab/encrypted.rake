namespace :gitlab do
  namespace :encrypted do
    desc 'GitLab | Encrypted | edit encrypted config files'
    task :edit,  [:path] => ['gitlab:encrypted:safe_mode', :environment] do |t, args|
      Gitlab::EncryptedCommand.edit(args[:path])
    end

    desc 'GitLab | Encrypted | show encrypted config files'
    task :show, [:path] => ['gitlab:encrypted:safe_mode', :environment] do |t, args|
      Gitlab::EncryptedCommand.show(args[:path])
    end

    task :safe_mode do
      ENV['GITLAB_ENCRYPTED_SAFE_MODE'] = 'true'
    end
  end
end
