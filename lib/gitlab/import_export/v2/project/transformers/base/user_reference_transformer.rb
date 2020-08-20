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
      data['issues'].each do |issue|
        USER_REFERENCES.each do |reference|
          if issue[reference] && issue[reference].is_a?(Array)
            issue[reference].map!(&method(:update_user_reference))
          elsif issue[reference]
            issue[reference] = update_user_reference(issue[reference])
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
