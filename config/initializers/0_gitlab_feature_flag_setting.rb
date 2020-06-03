require_relative '../settings'

#
# Feature Flag
#
Settings['feature_flags'] ||= Settingslogic.new({})
Settings.feature_flags['unleash'] ||= Settingslogic.new({})
Settings.feature_flags.unleash['enabled'] = false if Settings.feature_flags.unleash['enabled'].nil?
Settings.feature_flags['flipper'] ||= Settingslogic.new({})
Settings.feature_flags.flipper['enabled'] = false if Settings.feature_flags.flipper['enabled'].nil?
