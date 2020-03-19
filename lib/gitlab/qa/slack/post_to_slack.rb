module Gitlab
  module QA
    module Slack
      class PostToSlack
        def initialize(message:)
          @message = message
        end

        def invoke!
          Runtime::Env.require_slack_qa_channel!
          Runtime::Env.require_ci_slack_webhook_url!

          params = {}
          params['channel'] = Runtime::Env.slack_qa_channel
          params['username'] = "GitLab QA Bot"
          params['icon_emoji'] = Runtime::Env.slack_icon_emoji
          params['text'] = @message

          url = Runtime::Env.ci_slack_webhook_url

          Support::HttpRequest.make_http_request(method: 'post', url: url, params: params)
        end
      end
    end
  end
end
