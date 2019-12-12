# frozen_string_literal: true

module SnippetsActions
  extend ActiveSupport::Concern

  def edit
  end

  # rubocop:disable Gitlab/ModuleWithInstanceVariables
  def raw
    disposition = params[:inline] == 'false' ? 'attachment' : 'inline'

    workhorse_set_content_type!

    if Feature.enabled?(:version_snippets, current_user)
      content = @blob.data
      filename = @blob.name.gsub(/[^a-zA-Z0-9_\-\.]+/, '')
    else
      content = @snippet.content
      filename = @snippet.sanitized_file_name
    end

    send_data(
      convert_line_endings(content),
      type: 'text/plain; charset=utf-8',
      disposition: disposition,
      filename: filename
    )
  end
  # rubocop:enable Gitlab/ModuleWithInstanceVariables

  private

  def convert_line_endings(content)
    params[:line_ending] == 'raw' ? content : content.gsub(/\r\n/, "\n")
  end
end
