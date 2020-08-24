unless Rails.env.production?
  task :discover_unused_partials do
    require 'discover-unused-partials'
    require 'yaml'

    options = {}
    options[:root] = Rails.root
    config = File.join(Rails.root, 'config', 'discover-unused-partials.yml')
    options.merge!(YAML.load_file(config)) if File.exist?(config)
    # There is no good way to scan for render_if_exists yet,
    # or to scan both CE/EE at the same time.
    DiscoverUnusedPartials.find(options)
  end
end
