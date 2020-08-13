# frozen_string_literal: true

module Gitlab::ImportExport::V2::Project::Exporters
  class RelationExporter
    DEFAULT_PAGE = 1
    PER_PAGE = 300

    def self.export(*args)
      self.new(*args).export
    end

    def initialize(source:, relation:, page: DEFAULT_PAGE, per: PER_PAGE)
      @source = source
      @relation = relation.to_sym
      @page = page
      @per = per
    end

    def export
      return [] unless valid_relation?

      includes = relation_includes.find { |schema| schema.key?(@relation) }[@relation]

      @source.public_send(@relation).page(@page).per(@per).as_json(includes)
    end

    def valid_relation?
      valid_relations.include?(@relation) && @source.respond_to?(@relation)
    end

    def valid_relations
      @valid_relations ||= reader.project_tree[:include].flat_map(&:keys)
    end

    def relation_includes
      reader.project_tree[:include]
    end

    def reader
      @reader ||= Gitlab::ImportExport::Reader.new(shared: nil)
    end
  end
end
