# frozen_string_literal: true

require 'spec_helper'

describe WikiPages::UpdateService do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:page) { create(:wiki_page) }
  let(:page_title) { 'New Title' }

  let(:opts) do
    {
      content: 'New content for wiki page',
      format: 'markdown',
      message: 'New wiki message',
      title: page_title
    }
  end

  let(:bad_opts) do
    { title: '' }
  end

  subject(:service) { described_class.new(project, user, opts) }

  before do
    project.add_developer(user)
  end

  describe '#execute' do
    it 'updates the wiki page' do
      updated_page = service.execute(page)

      expect(updated_page).to be_valid
      expect(updated_page.message).to eq(opts[:message])
      expect(updated_page.content).to eq(opts[:content])
      expect(updated_page.format).to eq(opts[:format].to_sym)
      expect(updated_page.title).to eq(page_title)
    end

    it 'executes webhooks' do
      expect(service).to receive(:execute_hooks).once
        .with(instance_of(WikiPage), 'update', String)

      service.execute(page)
    end

    it 'counts edit events' do
      counter = Gitlab::UsageDataCounters::WikiPageCounter

      expect { service.execute page }.to change { counter.read(:update) }.by 1
    end

    shared_examples 'adds activity event' do
      it 'adds a new wiki page activity event' do
        expect { service.execute(page) }.to change { Event.count }.by 1

        expect(Event.recent.first).to have_attributes(
          action: Event::UPDATED,
          wiki_page: page,
          target_title: page.title
        )
      end
    end

    context 'the page is at the top level' do
      let(:page_title) { 'Top level page' }

      include_examples 'adds activity event'
    end

    context 'the page is in a subsection' do
      let(:page_title) { 'Subsection / secondary page' }

      include_examples 'adds activity event'
    end

    context 'when the options are bad' do
      subject(:service) { described_class.new(project, user, bad_opts) }

      it 'does not count an edit event' do
        counter = Gitlab::UsageDataCounters::WikiPageCounter

        expect { service.execute page }.not_to change { counter.read(:update) }
      end

      it 'does not record the activity' do
        expect { service.execute page }.not_to change(Event, :count)
      end

      it 'reports the error' do
        expect(service.execute page).to be_invalid
          .and have_attributes(errors: be_present)
      end
    end
  end
end
