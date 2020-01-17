# frozen_string_literal: true

module API
  module Entities
    class ProjectUpload < Grape::Entity
      expose :markdown_name, as: :alt
      expose :secure_url, as: :url
      expose :full_url do |uploader|
        ['/', uploader.model.full_path, uploader.secure_url].join
      end

      expose :markdown_link, as: :markdown
    end
  end
end
