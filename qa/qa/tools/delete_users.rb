# frozen_string_literal: true

require_relative '../../qa'

# This script deletes all users that follow a particular pattern
# Required environment variables: GITLAB_QA_ADMIN_ACCESS_TOKEN and GITLAB_ADDRESS
# Run `rake delete_users`

module QA
  module Tools
    class DeleteUsers
      include Support::Api

      def initialize
        raise ArgumentError, "Please provide GITLAB_ADDRESS" unless ENV['GITLAB_ADDRESS']
        raise ArgumentError, "Please provide GITLAB_QA_ADMIN_ACCESS_TOKEN" unless ENV['GITLAB_QA_ADMIN_ACCESS_TOKEN']

        @api_client = Runtime::API::Client.new(ENV['GITLAB_ADDRESS'], personal_access_token: ENV['GITLAB_QA_ADMIN_ACCESS_TOKEN'])

        # user.name should match
        @default_patterns = /(^eve <img.*$)/
      end

      def run
        puts "Deleting QA users"

        current_page = get Runtime::API::Request.new(@api_client, "/users", per_page: '300').url

        while (current_page = get(Runtime::API::Request.new(@api_client, "/users",
                                                             per_page: '300', page: current_page.headers[:x_next_page]).url)).headers[:x_next_page]
          JSON.parse(current_page.to_s).map do |user|
            if user["name"] =~ @default_patterns
              uid = user["id"]
              delete Runtime::API::Request.new(@api_client, "/users/#{uid}").url
              print "#{uid},"
            end
          end
        end

        puts "\nDone"
      end
    end
  end
end
