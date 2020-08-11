# frozen_string_literal: true

module CiConfiguration
  # This class parses SAST template file and .gitlab-ci.yml to populate default and current values into the JSON
  # read from app/validators/json_schemas/security_ci_configuration_schemas/sast_ui_schema.json
  class SastParserService < ::BaseService
    SAST_UI_SCHEMA_PATH = 'app/validators/json_schemas/security_ci_configuration_schemas/sast_ui_schema.json'
    SAST_TEMPLATE_PATH = 'lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml'

    def initialize(project)
      @project = project
    end

    def configuration
      config = Gitlab::Json.parse(File.read(Rails.root.join(SAST_UI_SCHEMA_PATH))).with_indifferent_access
      populate_values(config)
      config
    end

    private

    def sast_template_content
      File.read(Rails.root.join(SAST_TEMPLATE_PATH))
    end

    def populate_values(config)
      set_config_values(:default_value, config[:global], sast_template_attributes)
      set_config_values(:value, config[:global], gitlab_ci_yml_attributes) if @project.gitlab_ci_present?
      set_config_values(:default_value, config[:pipeline], sast_template_attributes)
      set_config_values(:value, config[:pipeline], gitlab_ci_yml_attributes) if @project.gitlab_ci_present?
    end

    def set_config_values(key, config_attributes, attributes)
      config_attributes.each do |entity|
        entity[key] = attributes[entity[:field]]
      end
    end

    def sast_template_attributes
      @sast_template_attributes ||= build_sast_attributes(sast_template_content)
    end

    def gitlab_ci_yml_attributes
      @gitlab_ci_yml_attributes ||= build_sast_attributes(@project.repository.gitlab_ci_yml_for(@project.repository.root_ref_sha))
    end

    def build_sast_attributes(content)
      sast_attributes = Gitlab::Ci::YamlProcessor.new(content).build_attributes(:sast)
      sast_attributes[:yaml_variables].each { |attribute| sast_attributes[attribute[:key]] = attribute[:value] }
      sast_attributes.with_indifferent_access
    end
  end
end
