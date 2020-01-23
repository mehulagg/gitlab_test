# frozen_string_literal: true

require 'mime/types'

module API
  class LsifDatabases < Grape::API
    before do
      Feature.enabled?(:code_navigation, user_project)

      require_repository_enabled!
      require_gitlab_workhorse!

      authorize! :push_code, user_project
    end

    params do
      requires :id, type: String, desc: 'The ID of a project'
      requires :commit_id, type: String, desc: 'The ID of a commit'
    end
    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      segment ':id/commits/:commit_id' do
        params do
          requires :file, type: File, desc: 'LSIF dump file'
        end
        post 'lsif/upload' do
          file = params[:file][:tempfile]

          uploader = LsifDatabaseUploader.new(@project, params[:commit_id])
          uploader.store!(file)
        end

        params do
          requires :path, type: String, desc: 'The path of a file'
        end
        segment 'lsif' do
          get 'info' do
            uploader = LsifDatabaseUploader.new(@project, params[:commit_id])
            uploader.retrieve_from_store!(uploader.filename)

            db = SQLite3::Database.new(uploader.file.file)

            doc_id, filepath = db.execute("SELECT documentHash, uri, MIN(LENGTH(uri)) FROM documents WHERE uri LIKE '%#{params[:path]}'").first
            prefix = filepath.delete_suffix(params[:path])

            ranges = db.execute("SELECT identifier, startLine, endLine, startCharacter, endCharacter FROM refs WHERE documentHash='#{doc_id}'")

            defs = db.execute("
                SELECT DISTINCT(defs.identifier), documents.uri, defs.startLine, defs.endLine, defs.startCharacter, defs.endCharacter FROM defs
                INNER JOIN documents ON defs.documentHash=documents.documentHash
                INNER JOIN refs ON refs.identifier = defs.identifier WHERE refs.documentHash='#{doc_id}'")
            def_for_ranges = defs.index_by { |(identifier)| identifier }

            hover_for_ranges =
              db.execute("
                SELECT DISTINCT(refs.identifier), blobs.content FROM blobs
                INNER JOIN hovers ON blobs.hash=hovers.hoverHash
                INNER JOIN refs ON refs.identifier = hovers.identifier WHERE refs.documentHash='#{doc_id}'").to_h

            ranges.map do |(identifier, start_line, end_line, start_char, end_char)|
              definition_url = def_for_ranges[identifier]&.yield_self do |(_, path, start_line, end_line, start_char, end_char)|
                blob_ref_path = File.join(params[:commit_id], path.delete_prefix(prefix))
                Gitlab::Routing.url_helpers.project_blob_url(@project, blob_ref_path, anchor: "L#{start_line + 1}")
              end

              {
                identifier: identifier,
                start_line: start_line,
                end_line: end_line,
                start_char: start_char,
                end_char: end_char,
                definition_url: definition_url,
                hover: hover_for_ranges[identifier] ? JSON.parse(hover_for_ranges[identifier])["contents"].map do |hover|
                  { language: hover["language"], value: Gitlab::Highlight.highlight(nil, hover["value"], language: hover["language"]) }
                end : nil
              }
            end
          end
        end
      end
    end
  end
end
