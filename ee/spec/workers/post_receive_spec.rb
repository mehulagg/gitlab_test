# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PostReceive do
  include AfterNextHelpers

  let(:changes) { "123456 789012 refs/heads/tést\n654321 210987 refs/tags/tag" }
  let(:changes_with_master) { "#{changes}\n423423 797823 refs/heads/master" }
  let(:wrongly_encoded_changes) { changes.encode("ISO-8859-1").force_encoding("UTF-8") }
  let(:base64_changes) { Base64.encode64(wrongly_encoded_changes) }
  let(:base64_changes_with_master) { Base64.encode64(changes_with_master) }
  let(:gl_repository) { "project-#{project.id}" }
  let(:key) { create(:key, user: project.owner) }
  let(:key_id) { key.shell_id }
  let(:project) { create(:project, :repository, :wiki_repo) }

  describe "#process_project_changes" do
    before do
      allow_next(Gitlab::GitPostReceive, to_receive: :identify, returning: project.owner)
    end

    context 'after project changes hooks' do
      let(:fake_hook_data) { Hash.new(event_name: 'repository_update') }

      before do
        allow(RepositoryPushAuditEventWorker).to receive(:perform_async)
        allow_next(Gitlab::DataBuilder::Repository)
          .to receive(:update).and_return(fake_hook_data)

        # silence hooks so we can isolate
        allow_next(Key).to receive(:post_create_hook).and_return(true)

        expect_next(Git::TagPushService).to receive(:execute).and_return(true)
        expect_next(Git::BranchPushService).to receive(:execute).and_return(true)
      end

      context 'when DB is readonly' do
        before do
          allow(Gitlab::Database).to receive(:read_only?) { true }
        end

        it 'does not call RepositoryPushAuditEventWorker' do
          expect(::RepositoryPushAuditEventWorker).not_to receive(:perform_async)

          described_class.new.perform(gl_repository, key_id, base64_changes)
        end
      end

      context 'when DB is not readonly' do
        before do
          allow(Gitlab::Database).to receive(:read_only?) { false }
        end

        it 'calls RepositoryPushAuditEventWorker' do
          expected_changes = [
            { after: '789012', before: '123456', ref: 'refs/heads/tést' },
            { after: '210987', before: '654321', ref: 'refs/tags/tag' }
          ]

          expect(::RepositoryPushAuditEventWorker).to receive(:perform_async)
            .with(expected_changes, project.id, project.owner.id)

          described_class.new.perform(gl_repository, key_id, base64_changes)
        end

        context 'when feature flag is off' do
          before do
            stub_feature_flags(repository_push_audit_event: false)
          end

          it 'does not call RepositoryPushAuditEventWorker' do
            expect(::RepositoryPushAuditEventWorker).not_to receive(:perform_async)

            described_class.new.perform(gl_repository, key_id, base64_changes)
          end
        end
      end

      it 'calls Geo::RepositoryUpdatedService when running on a Geo primary node' do
        allow(Gitlab::Geo).to receive(:primary?) { true }

        expect_execution(::Geo::RepositoryUpdatedService)

        described_class.new.perform(gl_repository, key_id, base64_changes)
      end

      it 'does not call Geo::RepositoryUpdatedService when not running on a Geo primary node' do
        allow(Gitlab::Geo).to receive(:primary?) { false }

        expect(::Geo::RepositoryUpdatedService).not_to receive(:new)

        described_class.new.perform(gl_repository, key_id, base64_changes)
      end
    end
  end

  describe '#process_wiki_changes' do
    let(:gl_repository) { "wiki-#{project.id}" }

    it 'calls Git::WikiPushService#process_changes' do
      expect_next(::Git::WikiPushService).to receive(:process_changes)

      described_class.new.perform(gl_repository, key_id, base64_changes)
    end

    context 'assuming calls to process_changes are successful' do
      before do
        # We instantiate the wiki here so that expect_next(ProjectWiki) captures the right thing.
        project.wiki

        allow_next(Git::WikiPushService).to receive(:process_changes)
      end

      it 'calls Geo::RepositoryUpdatedService when running on a Geo primary node' do
        allow(Gitlab::Geo).to receive(:primary?) { true }

        expect_execution(::Geo::RepositoryUpdatedService)

        described_class.new.perform(gl_repository, key_id, base64_changes)
      end

      it 'does not call Geo::RepositoryUpdatedService when not running on a Geo primary node' do
        allow(Gitlab::Geo).to receive(:primary?) { false }

        expect(::Geo::RepositoryUpdatedService).not_to receive(:new)

        described_class.new.perform(gl_repository, key_id, base64_changes)
      end

      it 'triggers wiki index update when ElasticSearch is enabled and pushed to master', :elastic do
        stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)

        expect_next(ProjectWiki).to receive(:index_wiki_blobs)

        described_class.new.perform(gl_repository, key_id, base64_changes_with_master)
      end

      it 'does not trigger wiki index update when Elasticsearch is enabled and not pushed to master', :elastic do
        stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)

        expect_next(ProjectWiki).not_to receive(:index_wiki_blobs)

        described_class.new.perform(gl_repository, key_id, base64_changes)
      end

      context 'when limited indexing is on', :elastic do
        before do
          stub_ee_application_setting(
            elasticsearch_search: true,
            elasticsearch_indexing: true,
            elasticsearch_limit_indexing: true
          )
        end

        context 'when the project is not enabled specifically' do
          it 'does not trigger wiki index update' do
            expect_next(ProjectWiki).not_to receive(:index_wiki_blobs)

            described_class.new.perform(gl_repository, key_id, base64_changes_with_master)
          end
        end

        context 'when a project is enabled specifically' do
          before do
            create :elasticsearch_indexed_project, project: project
          end

          it 'triggers wiki index update' do
            expect_next(ProjectWiki).to receive(:index_wiki_blobs)

            described_class.new.perform(gl_repository, key_id, base64_changes_with_master)
          end
        end

        context 'when a group is enabled' do
          let(:user) { create(:user) }
          let(:group) { create(:group) }
          let(:project) { create(:project, :wiki_repo, group: group) }
          let(:key) { create(:key, user: user) }

          before do
            create :elasticsearch_indexed_namespace, namespace: group
            group.add_owner(user)
          end

          it 'triggers wiki index update' do
            project.wiki
            expect_next(ProjectWiki, to_receive: :index_wiki_blobs)

            described_class.new.perform(gl_repository, key_id, base64_changes_with_master)
          end
        end
      end
    end
  end
end
