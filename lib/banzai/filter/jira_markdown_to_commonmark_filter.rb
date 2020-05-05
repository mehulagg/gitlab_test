# frozen_string_literal: true

# Uses Pandoc to convert from jira wiki markdown into CommonMark
# https://jira.atlassian.com/secure/WikiRendererHelpAction.jspa
module Banzai
  module Filter
    class JiraMarkdownToCommonmarkFilter < HTML::Pipeline::TextFilter
      def initialize(text, context = nil, result = nil)
        super(text, context, result)

        @text = @text.delete("\r")
      end

      def call
        PandocRuby.convert(@text, from: :jira, to: :gfm)
      end
    end
  end
end
