# frozen_string_literal: true

require 'asciidoctor'

module Gitlab
  module Asciidoc
    # Mermaid BlockProcessor
    class MermaidBlockProcessor < ::Asciidoctor::Extensions::BlockProcessor
      use_dsl

      named :mermaid
      on_context :literal, :listing
      parse_content_as :simple

      def process(parent, reader, attrs)
        create_mermaid_source_block(parent, reader.read, attrs)
      end

      private

      def create_mermaid_source_block(parent, content, attrs)
        html = %(<div><pre data-mermaid-style="display">#{content}</pre></div>)
        ::Asciidoctor::Block.new(parent, :pass, {
            content_model: :raw,
            source: html,
            subs: :default
        }.merge(attrs))
      end
    end
  end
end
