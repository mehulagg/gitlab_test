# frozen_string_literal: true

module Gitlab
  class DemoTemplate
    attr_reader :title, :name, :description, :preview, :logo

    def initialize(name, title, description, preview, logo = 'illustrations/gitlab_logo.svg')
      @name, @title, @description, @preview, @logo = name, title, description, preview, logo
    end

    def file
      archive_path.open
    end

    def archive_path
      self.class.archive_directory.join(archive_filename)
    end

    def archive_filename
      "#{name}.tar.gz"
    end

    def clone_url
      "#{preview}.git"
    end

    def project_path
      URI.parse(preview).path.sub(%r{\A/}, '')
    end

    def uri_encoded_project_path
      ERB::Util.url_encode(project_path)
    end

    def ==(other)
      name == other.name && title == other.title
    end

    def self.localized_templates_table
      [
        DemoTemplate.new('demo_template', 'Demo Template (test)', _('Test template for Demo Templates.'), 'https://gitlab.com/gitlab-org/project-templates', 'illustrations/gitlab_logo.svg'),
      ].freeze
    end

    class << self
      def all
        localized_templates_table
      end

      def find(name)
        all.find { |template| template.name == name.to_s }
      end

      def archive_directory
        Rails.root.join("vendor/demo_templates")
      end
    end
  end
end
