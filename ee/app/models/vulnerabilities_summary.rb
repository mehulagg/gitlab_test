# frozen_string_literal: true

VulnerabilitiesSummary = Struct.new(
  *::Vulnerabilities::Occurrence::SEVERITY_LEVELS.keys.map(&:to_sym).push(:vulnerable),
  keyword_init: true
)
