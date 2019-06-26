# frozen_string_literal: true

module DesignManagement
  class DesignCollection
    attr_reader :issue

    delegate :designs, :project, to: :issue

    def initialize(issue)
      @issue = issue
    end

    def find_or_create_design!(filename:)
      designs.find { |design| design.filename == filename } ||
        designs.safe_find_or_create_by!(project: project, filename: filename)
    end

    # like designs.where(filename: filenames) with error checking for two invariants:
    #  * we actually have something to find (the input array is not empty)
    #  * we find everything we are looking for
    def find_all_designs_by_filename(filenames)
      raise ArgumentError, 'filenames must not be empty' \
        if filenames.nil? || filenames.empty?

      found = designs.where(filename: filenames)

      raise "Expected to find #{filenames.size} designs, but only found #{found.size}" \
        if found.size != filenames.size

      found
    end

    def versions
      @versions ||= DesignManagement::Version.for_designs(designs)
    end

    def repository
      project.design_repository
    end
  end
end
