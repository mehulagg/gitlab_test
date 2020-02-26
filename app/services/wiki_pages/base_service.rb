# frozen_string_literal: true

module WikiPages
  class BaseService < ::BaseService
    private

    def execute_hooks(page, action = 'create', old_slug = nil)
      page_data = Gitlab::DataBuilder::WikiPage.build(page, current_user, action)
      @project.execute_hooks(page_data, :wiki_page_hooks)
      @project.execute_services(page_data, :wiki_page_hooks)
      increment_usage(action)
      EventCreateService.new.wiki_event(page, wiki_action(action), old_slug)
    end

    # This method throws an error if the action is an unanticipated value.
    def increment_usage(action)
      Gitlab::UsageDataCounters::WikiPageCounter.count(action)
    end

    def wiki_action(name)
      mapping = { create: :created, update: :updated, delete: :destroyed }
      ::Event::ACTIONS[mapping[name.to_sym]]
    end
  end
end

WikiPages::BaseService.prepend_if_ee('EE::WikiPages::BaseService')
