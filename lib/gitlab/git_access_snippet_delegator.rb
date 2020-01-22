# frozen_string_literal: true

module Gitlab
  class GitAccessSnippetDelegator
    def initialize(*args)
      snippet = args[1]
      checker_class = snippet.is_a?(PersonalSnippet) ? GitAccessPersonalSnippet : GitAccessProjectSnippet
      @checker = checker_class.new(*args)
    end

    delegate :check, to: :@checker
  end
end
