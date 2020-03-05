# frozen_string_literal: true

module Git
  class WikiPushService < ::BaseService
    def execute
      changed_files.each do |raw_change|
        page = find_page(raw_change)
        next unless page.present?

        EventCreateService.new.wiki_event(page, event_action(raw_change), strip_extension(raw_change.old_path))
      end
    end

    private

    def project_wiki
      @project_wiki ||= ProjectWiki.new(project, current_user)
    end

    def event_action(raw_change)
      action = if raw_change.old_path.nil?
                 :created
               elsif raw_change.new_path.nil?
                 :destroyed
               else
                 :updated
               end

      ::Event::ACTIONS[action]
    end

    def find_page(raw_change)
      filename = raw_change.new_path.presence || raw_change.old_path
      return unless filename.present?

      slug = strip_extension(filename)
      project_wiki.find_page(slug)
    end

    def strip_extension(filename)
      return unless filename

      ext = File.extname(filename)
      filename.chomp(ext)
    end

    def changed_in(change)
      branch_name = ::Gitlab::Git.ref_name(change[:ref])
      return [] unless project_wiki.default_branch == branch_name

      project_wiki.repository.raw.raw_changes_between(change[:oldrev], change[:newrev])
    end

    # See: [Gitlab::GitPostReceive#changes]
    def changes
      params[:changes] || []
    end

    def changed_files
      changes.flat_map { |change| changed_in(change) }
    end
  end
end

Git::WikiPushService.prepend_if_ee('EE::Git::WikiPushService')
