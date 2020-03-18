module Gitlab
  module QA
    module Slack
      class PostToSlack
        def initialize(message:)
          @message = message
        end

        def invoke!
          Runtime::Env.require_slack_qa_channel!
          Runtime::Env.require_slack_qa_bot_token!

          params = {}
          params['token'] = Runtime::Env.slack_qa_bot_token
          params['channel'] = Runtime::Env.slack_qa_channel
          params['text'] = @message

          url = "https://slack.com/api/chat.postMessage"

          Support::HttpRequest.make_http_request(method: 'post', url: url, params: params)
        end
      end
    end
  end
end
