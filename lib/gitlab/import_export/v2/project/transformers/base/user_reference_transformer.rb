# frozen_string_literal: true

module Gitlab::ImportExport::V2::Project::Transformers::Base
  class UserReferenceTransformer
    USER_REFERENCES = %w[
      author
      assignee
      assignees
      user
    ].freeze

    # Transform user references to User objects by email. Falls back to importer user
    # {"author" => {"email": "test@gitlab.com"}} => {"author" => #<User id:1 @root>}
    # {"assignees" => [{"email": "test@gitlab.com"}, ...]} => {"assignees" => [#<User id:1 @root>, ...]}
    def self.transform(data)
      update_user_references(data)
    end

    def self.update_user_references(data)
      data.each do |key, value|
        if data[key].is_a?(Hash)
          update_user_references(data[key])
        elsif data[key].is_a?(Array)
          data[key].map!(&method(:update_user_references))
        end

        if USER_REFERENCES.include?(key)
          if value && value.is_a?(Array)
            data[key].map!(&method(:update_user_reference))
          elsif value
            data[key] = update_user_reference(value)
          end
        end
      end

      data
    end

    def self.update_user_reference(reference)
      User.find_by_email(reference['email']) || User.first
    end
  end
end
