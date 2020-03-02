# This file contains environment settings for gitaly when it's running
# as part of the gitlab-ce/ee test suite.
#
# Please be careful when modifying this file. Your changes must work
# both for local development rspec runs, and in CI.

require 'socket'

module GitalyTest
  def tmp_tests_gitaly_dir
    File.expand_path('../tmp/tests/gitaly', __dir__)
  end

  def gemfile
    File.join(tmp_tests_gitaly_dir, 'ruby', 'Gemfile')
  end

  def env
    env_hash = {
      'HOME' => File.expand_path('tmp/tests'),
      'GEM_PATH' => Gem.path.join(':'),
      'BUNDLE_APP_CONFIG' => File.join(File.dirname(gemfile), '.bundle/config'),
      'BUNDLE_FLAGS' => "--jobs=4 --retry=3",
      'BUNDLE_INSTALL_FLAGS' => nil,
      'BUNDLE_GEMFILE' => gemfile,
      'RUBYOPT' => nil,

      # Git hooks can't run during tests as the internal API is not running.
      'GITALY_TESTING_NO_GIT_HOOKS' => "1"
    }

    if ENV['CI']
      bundle_path = File.expand_path('../vendor/gitaly-ruby', __dir__)
      env_hash['BUNDLE_FLAGS'] << " --path=#{bundle_path}"
    end

    env_hash
  end

  def config_path(service)
    case service
    when 'gitaly' then
      File.join(tmp_tests_gitaly_dir, 'config.toml')
    when 'praefect' then
      File.join(tmp_tests_gitaly_dir, 'praefect.config.toml')
    end
  end

  def start(service)
    args = %W[#{tmp_tests_gitaly_dir}/#{service}]
    args.push("-config") if service == 'praefect'
    args.push(config_path(service))

    pid = spawn(env, *args, [:out, :err] => "log/#{service}-test.log")

    begin
      try_connect!(service)
    rescue
      Process.kill('TERM', pid)
      raise
    end

    pid
  end

  def check_gitaly_config!
    puts "Checking gitaly-ruby Gemfile..."

    unless File.exist?(gemfile)
      message = "#{gemfile} does not exist."
      message += "\n\nThis might have happened if the CI artifacts for this build were destroyed." if ENV['CI']
      abort message
    end

    puts 'Checking gitaly-ruby bundle...'
    abort 'bundle check failed' unless system(env, 'bundle', 'check', chdir: File.dirname(gemfile))
  end

  def read_socket_path(service)
    # This code needs to work in an environment where we cannot use bundler,
    # so we cannot easily use the toml-rb gem. This ad-hoc parser should be
    # good enough.
    config_text = IO.read(config_path(service))

    config_text.lines.each do |line|
      match_data = line.match(/^\s*socket_path\s*=\s*"([^"]*)"$/)

      return match_data[1] if match_data
    end

    raise "failed to find socket_path in #{config_path(service)}"
  end

  def try_connect!(service)
    print "Trying to connect to #{service}: "
    timeout = 20
    delay = 0.1
    socket = read_socket_path(service)

    Integer(timeout / delay).times do
      UNIXSocket.new(socket)
      puts ' OK'

      return
    rescue Errno::ENOENT, Errno::ECONNREFUSED
      print '.'
      sleep delay
    end

    puts ' FAILED'

    raise "could not connect to #{socket}"
  end
end
