# frozen_string_literal: true

require 'active_support/core_ext/object/blank'

module QA
  module Runtime
    module Feature
      # Documentation: https://docs.gitlab.com/ee/api/features.html

      extend self
      extend Support::Api

      SetFeatureError = Class.new(RuntimeError)
      AuthorizationError = Class.new(RuntimeError)
      UnknownScopeError = Class.new(RuntimeError)

      def enable(key, **scopes)
        QA::Runtime::Logger.info("Enabling feature: #{key}")
        set_feature(key, true, scopes)
      end

      def disable(key, **scopes)
        QA::Runtime::Logger.info("Disabling feature: #{key}")
        set_feature(key, false, scopes)
      end

      def remove(key)
        request = Runtime::API::Request.new(api_client, "/features/#{key}")
        response = delete(request.url)
        unless response.code == QA::Support::Api::HTTP_STATUS_NO_CONTENT
          raise SetFeatureError, "Deleting feature flag #{key} failed with `#{response}`."
        end
      end

      def enable_and_verify(key, **scopes)
        set_and_verify(key, enable: true, **scopes)
      end

      def disable_and_verify(key, **scopes)
        set_and_verify(key, enable: false, **scopes)
      end

      def enabled?(key, **scopes)
        feature = JSON.parse(get_features).find { |flag| flag['name'] == key }
        feature && feature['state'] == 'on' || feature['state'] == 'conditional' && scopes.present? && enabled_scope?(feature['gates'], scopes)
      end

      def enabled_scope?(gates, scopes)
        scopes.each do |key, value|
          case key
          when :project, :group, :user
            actors = gates.filter { |i| i['key'] == 'actors' }.first['value']
            break actors.include?("#{key.to_s.capitalize}:#{value.id}")
          when :feature_group
            groups = gates.filter { |i| i['key'] == 'groups' }.first['value']
            break groups.include?(value)
          else
            raise UnknownScopeError, "Unknown scope: #{key}"
          end
        end
      end

      def get_features
        request = Runtime::API::Request.new(api_client, '/features')
        response = get(request.url)
        response.body
      end

      private

      def api_client
        @api_client ||= begin
          if Runtime::Env.admin_personal_access_token
            Runtime::API::Client.new(:gitlab, personal_access_token: Runtime::Env.admin_personal_access_token)
          else
            user = Resource::User.fabricate_via_api! do |user|
              user.username = Runtime::User.admin_username
              user.password = Runtime::User.admin_password
            end

            unless user.admin?
              raise AuthorizationError, "Administrator access is required to enable/disable feature flags. User '#{user.username}' is not an administrator."
            end

            Runtime::API::Client.new(:gitlab, user: user)
          end
        end
      end

      # Change a feature flag and verify that the change was successful
      # Arguments:
      #   key: The feature flag to set (as a string)
      #   enable: `true` to enable the flag, `false` to disable it
      def set_and_verify(key, enable:, **scopes)
        Support::Retrier.retry_on_exception(sleep_interval: 2) do
          enable ? enable(key, scopes) : disable(key, scopes)

          is_enabled = nil

          QA::Support::Waiter.wait_until(sleep_interval: 1) do
            is_enabled = enabled?(key, scopes)
            is_enabled == enable
          end

          raise SetFeatureError, "#{key} was not #{enable ? 'enabled' : 'disabled'}!" unless is_enabled == enable

          QA::Runtime::Logger.info("Successfully #{enable ? 'enabled' : 'disabled'} and verified feature flag: #{key}")
        end
      end

      def set_feature(key, value, **scopes)
        request = Runtime::API::Request.new(api_client, "/features/#{key}")
        scopes[:project] = scopes[:project].full_path if scopes.key?(:project)
        scopes[:group] = scopes[:group].full_path if scopes.key?(:group)
        scopes[:user] = scopes[:user].username if scopes.key?(:user)
        response = post(request.url, scopes.merge({ value: value }))
        unless response.code == QA::Support::Api::HTTP_STATUS_CREATED
          raise SetFeatureError, "Setting feature flag #{key} to #{value} failed with `#{response}`."
        end
      end
    end
  end
end
