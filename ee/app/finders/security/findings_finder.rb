# frozen_string_literal: true

# Security::FindingsFinder
#
# Used to find Ci::Builds associated with requested findings.
#
# Arguments:
#   pipeline - object to filter findings
#   params:
#     severity:    Array<String>
#     confidence:  Array<String>
#     report_type: Array<String>
#     scope:       String
#     page:        Int
#     per_page:    Int

module Security
  class FindingsFinder
    ResultSet = Struct.new(:relation, :findings) do
      delegate :current_page, :limit_value, :total_pages, :total_count, :next_page, :prev_page, to: :relation
    end

    DEFAULT_PAGE = 1
    DEFAULT_PER_PAGE = 20

    def initialize(pipeline, params: {})
      self.pipeline = pipeline
      self.params = params
    end

    def execute
      return unless has_security_findings?

      ResultSet.new(security_findings, findings)
    end

    private

    attr_accessor :pipeline, :params
    delegate :project, :has_security_findings?, to: :pipeline, private: true

    def findings
      security_findings.map do |security_finding|
        build_vulnerability_finding(security_finding)
      end
    end

    def build_vulnerability_finding(security_finding)
      report_finding = report_finding_for(security_finding)
      return Vulnerabilities::Finding.new unless report_finding

      finding_data = report_finding.to_hash.except(:compare_key, :identifiers, :location, :scanner)
      identifiers = report_finding.identifiers.map do |identifier|
        Vulnerabilities::Identifier.new(identifier.to_hash)
      end

      Vulnerabilities::Finding.new(finding_data).tap do |finding|
        finding.location_fingerprint = report_finding.location.fingerprint
        finding.vulnerability = vulnerability_for(security_finding)
        finding.project = project
        finding.sha = pipeline.sha
        finding.scanner = security_finding.scanner
        finding.identifiers = identifiers
      end
    end

    def report_finding_for(security_finding)
      report_findings.dig(security_finding.scan.scan_type, security_finding.project_fingerprint)&.first
    end

    def vulnerability_for(security_finding)
      vulnerabilties.dig(security_finding.scan.scan_type, security_finding.project_fingerprint)&.first
    end

    def vulnerabilties
      @vulnerabilties ||= security_findings.group_by(&:scan).each_with_object({}) do |(scan, findings), memo|
        memo[scan.scan_type] = vulnerabilities_for(scan.scan_type, findings.map(&:project_fingerprint))
      end
    end

    def vulnerabilities_for(report_type, project_fingerprints)
      project.vulnerabilities
             .with_findings
             .with_report_types(report_type)
             .by_project_fingerprints(project_fingerprints)
             .group_by { |v| v.finding.project_fingerprint }
    end

    def report_findings
      @report_findings ||= security_reports.transform_values { |report| report.findings.group_by(&:project_fingerprint) }
    end

    def security_reports
      ::Gitlab::Ci::Reports::Security::Reports.new(self).tap do |security_reports|
        builds.each { |build| build.collect_security_reports!(security_reports) }
      end.reports
    end

    def builds
      security_findings.map(&:build).uniq
    end

    def security_findings
      @security_findings ||= include_dismissed? ? all_security_findings : all_security_findings.undismissed
    end

    def all_security_findings
      pipeline.security_findings
              .with_build
              .with_scan
              .by_confidence_levels(confidence_levels)
              .by_report_types(report_types)
              .by_severity_levels(severity_levels)
              .ordered
              .page(page)
              .per(per_page)
    end

    def per_page
      @per_page ||= params[:per_page] || DEFAULT_PER_PAGE
    end

    def page
      @page ||= params[:page] || DEFAULT_PAGE
    end

    def include_dismissed?
      params[:scope] == 'all'
    end

    def confidence_levels
      params[:confidence] || Vulnerabilities::Finding.confidences.keys
    end

    def report_types
      params[:report_type] || Vulnerabilities::Finding.report_types.keys
    end

    def severity_levels
      params[:severity] || Vulnerabilities::Finding.severities.keys
    end
  end
end
