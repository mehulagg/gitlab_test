# frozen_string_literal: true

module SCA
  class LicenseDiff
    def initialize(base, head)
      @base = base
      @head = head
    end

    def diff
      @base.license_scan_report.diff_with(@head.license_scan_report)
    end
  end
end
