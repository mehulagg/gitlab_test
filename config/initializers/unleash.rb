return unless Gitlab.config.unleash.enabled && defined?(::Unicorn)

FeatureFlag::Adapters::Unleash.configure
UNLEASH = Unleash::Client.new
