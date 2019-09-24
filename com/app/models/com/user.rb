# frozen_string_literal: true
module Com
  module User
    extend ActiveSupport::Concern
    MAX_USERNAME_SUGGESTION_ATTEMPTS = 15

    class_methods do
      def username_suggestion(base_name)
        suffix = nil
        base_name = base_name.parameterize(separator: '_')
        MAX_USERNAME_SUGGESTION_ATTEMPTS.times do |attempt|
          username = "#{base_name}#{suffix}"
          return username unless ::Namespace.find_by_path_or_name(username)

          suffix = attempt + 1
        end

        ''
      end
    end
  end
end
