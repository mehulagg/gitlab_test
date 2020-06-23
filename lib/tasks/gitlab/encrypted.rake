namespace :gitlab do
  namespace :encrypted do
    task :safe_mode do
      ENV['GITLAB_ENCRYPTED_SAFE_MODE'] = 'true'
    end
  end
end
