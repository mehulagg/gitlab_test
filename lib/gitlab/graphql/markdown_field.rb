# frozen_string_literal: true

module Gitlab
  module Graphql
    module MarkdownField
      extend ActiveSupport::Concern

      prepended do
        def self.markdown_field(name, **kwargs)
          if kwargs[:resolver].present? || kwargs[:resolve].present?
            raise ArgumentError, 'Only `method` is allowed to specify the markdown field'
          end

          method_name = kwargs.delete(:method) || name.to_s.sub(/_html$/, '')
          # kwargs[:resolve] = Gitlab::Graphql::MarkdownField::Resolver.new(method_name.to_sym).proc
          # kwargs[:resolver] = Gitlab::Graphql::MarkdownField::Resolver.new(method_name.to_sym).proc
          kwargs[:method] = "#{method_name}_resolve"

          kwargs[:description] ||= "The GitLab Flavored Markdown rendering of `#{method_name}`"
          # Adding complexity to rendered notes since that could cause queries.
          kwargs[:complexity] ||= 5

          field name, GraphQL::STRING_TYPE, **kwargs

          self.instance_eval do
            define_method "#{method_name}_resolve" do
              ::Gitlab::Graphql::MarkdownField::Resolver.new("#{method_name}".to_sym).resolve(object, context)
            end
          end
        end
      end
    end
  end
end
