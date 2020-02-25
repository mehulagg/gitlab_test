# frozen_string_literal: true

module Banzai
  module Filter
    # Replaces placeholders for broadcast messages with data from the current
    # user or the instance.
    class BroadcastMessagePlaceholdersFilter < HTML::Pipeline::Filter
      def call
        return doc unless context[:broadcast_message_placeholders]

        doc.traverse do |node|
          if node.text? && !node.content.empty?
            node.content = replace_placeholders(node.content)
          end

          if href = link_href(node)
            href.value = replace_placeholders(href.value)
          end
        end

        doc
      end

      private

      def link_href(node)
        node.element? &&
          node.name == 'a' &&
          !node.attribute_nodes.empty? &&
          node.attribute_nodes.select { |a| a.name == "href" }.first
      end

      PLACEHOLDERS = {
        "email" => :email_address,
        "name" => :name,
        "user_id" => :user_id,
        "username" => :username,
        "instance_id" => :instance_id
      }.freeze

      def replace_placeholders(content)
        PLACEHOLDERS.each do |placeholder, method|
          regex = Regexp.new("{{#{placeholder}}}|%7B%7B#{placeholder}%7D%7D") # Also replace encoded URLs
          content.gsub!(regex, send(method).to_s) # rubocop:disable GitlabSecurity/PublicSend
        end

        content
      end

      def current_user
        context[:current_user]
      end

      def email_address
        current_user.try(:email)
      end

      def name
        current_user.try(:name)
      end

      def user_id
        current_user.try(:id)
      end

      def username
        current_user.try(:username)
      end

      def instance_id
        Gitlab::CurrentSettings.try(:uuid)
      end
    end
  end
end
