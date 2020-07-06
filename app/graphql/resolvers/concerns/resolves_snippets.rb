# frozen_string_literal: true

module ResolvesSnippets
  extend ActiveSupport::Concern

  included do
    type Types::SnippetType, null: false

    argument :ids, [::Types::GlobalIDType[Snippet]],
             required: false,
             description: 'Array of global snippet ids, e.g., "gid://gitlab/ProjectSnippet/1"'

    argument :visibility, Types::Snippets::VisibilityScopesEnum,
             required: false,
             description: 'The visibility of the snippet'
  end

  def resolve(**args)
    resolve_snippets(args)
  end

  private

  def resolve_snippets(args)
    SnippetsFinder.new(context[:current_user], snippet_finder_params(args)).execute
  end

  def snippet_finder_params(args)
    {
      ids: resolve_ids(args[:ids]),
      scope: args[:visibility]
    }.merge(options_by_type(args[:type]))
  end

  def resolve_ids(ids)
    Array.wrap(ids).compact.map(&:model_id)
  end

  def options_by_type(type)
    case type
    when 'personal'
      { only_personal: true }
    when 'project'
      { only_project: true }
    else
      {}
    end
  end
end
