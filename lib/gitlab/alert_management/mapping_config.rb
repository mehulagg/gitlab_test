# frozen_string_literal: true

module Gitlab
  module AlertManagement
    # YAML format (alpha)
    #
    # name: prometheus
    # fields:
    #   start_at: startsAt
    #   title:
    #     - annotations.title
    #     - annotations.summary
    #     - labels.alertname
    #
    # OR
    #
    # name: prometheus
    # fields:
    #   start_at:
    #     type: date
    #     map_from: startsAt
    #   title:
    #     type: string
    #     map_from:
    #       - annotations.title
    #       - annotations.summary
    #       - labels.alertname
    #
    class MappingConfig < Struct.new(:name, :fields, keyword_init: true)
      class Field < Struct.new(:name, :type, :map_from, keyword_init: true)
        def self.from_yaml(name, yaml)
          type, map_from =
            case yaml
            when Hash
              [yaml['type'] || 'any', yaml['map_from']]
            else
              ['any', yaml]
            end

          new(
            name: name,
            type: type,
            map_from: Array(map_from)
          )
        end
      end

      def self.from_yaml(yaml)
        new(
          name: yaml.fetch('name'),
          fields: map_fields(yaml.fetch('fields'))
        )
      end

      def self.map_fields(fields)
        fields.map do |name, hash|
          Field.from_yaml(name, hash)
        end
      end
    end
  end
end
