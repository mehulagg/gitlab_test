module Gitlab
  module QA
    module Slack
      class PostToSlack
        def initialize(message:, icon_emoji: Runtime::Env.slack_icon_emoji, channel: Runtime::Env.slack_qa_channel)
          @channel = channel
          @message = message
          @icon_emoji = icon_emoji
        end

        def invoke!
          Runtime::Env.require_slack_qa_channel! unless @channel
          Runtime::Env.require_ci_slack_webhook_url!

          params = {}
          params['channel'] = @channel
          params['username'] = "GitLab QA Bot"
          params['icon_emoji'] = @icon_emoji
          params['text'] = @message

          url = Runtime::Env.ci_slack_webhook_url

          Support::HttpRequest.make_http_request(method: 'post', url: url, params: params, show_response: true)
        end
      end
    end
  end
end
