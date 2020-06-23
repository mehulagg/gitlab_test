# frozen_string_literal: true

def enable_oj?
  return false unless Feature::FlipperFeature.table_exists?

  Feature.enabled?(:oj_json, default_enabled: true)
rescue
  false
end

# Toggling the feature flag used here will require an app restart.
#
# Oj will still show as MultiJson.default_adapter, but
# MultiJson.adapter will be :ok_json (the standard library) and Oj
# will not be mimicking the JSON constant.

if enable_oj?
  MultiJson.use(:oj)

  Oj.default_options = { mode: :object }
else
  MultiJson.use(:ok_json)
end
