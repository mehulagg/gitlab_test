# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GitAccessProject do
  let_it_be(:user, reload: true) { create(:user) }
  let_it_be(:project, refind: true) { create(:project, :repository) }

  let(:container) { project }
  let(:actor) { user }
  let(:project_path) { project.path }
  let(:namespace_path) { project&.namespace&.path }
  let(:protocol) { 'ssh' }
  let(:authentication_abilities) { %i[read_project download_code push_code] }
  let(:changes) { Gitlab::GitAccess::ANY }
  let(:push_access_check) { access.check('git-receive-pack', changes) }
  let(:pull_access_check) { access.check('git-upload-pack', changes) }
  let(:access) do
    described_class.new(actor, container, protocol,
                        authentication_abilities: authentication_abilities,
                        repository_path: project_path, namespace_path: namespace_path)
  end

  describe '#check_namespace!' do
    context 'when namespace is nil' do
      let(:namespace_path) { nil }

      it 'does not allow push and pull access' do
        aggregate_failures do
          expect { push_access_check }.to raise_namespace_not_found
          expect { pull_access_check }.to raise_namespace_not_found
        end
      end
    end
  end

  describe '#check_push_access!' do
    let_it_be(:unprotected_branch) { 'unprotected_branch' }

    let_it_be(:merge_into_protected_branch) do
      project.repository.add_branch(user, unprotected_branch, 'feature')
      rugged = rugged_repo(project.repository)
      target_branch = rugged.rev_parse('feature')
      source_branch = project.repository.create_file(
        user,
        'filename',
        'This is the file content',
        message: 'This is a good commit message',
        branch_name: unprotected_branch)
      author = { email: "email@example.com", time: Time.now, name: "Example Git User" }
      tree = rugged.merge_commits(target_branch, source_branch).write_tree(rugged)

      Rugged::Commit.create(rugged,
                            author: author,
                            committer: author,
                            message: "commit message",
                            parents: [target_branch, source_branch],
                            tree: tree)
    end

    let_it_be(:merge_request, reload: true) do
      create(:merge_request, source_project: project,
             source_branch: unprotected_branch,
             target_branch: 'feature')
    end

    let(:changes) do
      case action
      when :any
        Gitlab::GitAccess::ANY
      when :push_new_branch
        "#{Gitlab::Git::BLANK_SHA} 570e7b2ab refs/heads/wow"
      when :push_master
        '6f6d7e7ed 570e7b2ab refs/heads/master'
      when :push_protected_branch
        '6f6d7e7ed 570e7b2ab refs/heads/feature'
      when :push_remove_protected_branch
        "570e7b2ab #{Gitlab::Git::BLANK_SHA} refs/heads/feature"
      when :push_tag
        '6f6d7e7ed 570e7b2ab refs/tags/v1.0.0'
      when :push_new_tag
        "#{Gitlab::Git::BLANK_SHA} 570e7b2ab refs/tags/v7.8.9"
      when :push_all
        ['6f6d7e7ed 570e7b2ab refs/heads/master', '6f6d7e7ed 570e7b2ab refs/heads/feature']
      when :merge_into_protected_branch
        "0b4bc9a #{merge_into_protected_branch} refs/heads/feature"
      else
        raise 'Unknown action. Perhaps you need to update the case statement?'
      end
    end

    shared_examples 'protected branch checks' do
      using RSpec::Parameterized::TableSyntax

      where(:role, :action, :base_allowed) do
        :admin      |  :any                           | true
        :admin      |  :push_new_branch               | true
        :admin      |  :push_master                   | true
        :admin      |  :push_protected_branch         | true
        :admin      |  :push_remove_protected_branch  | false
        :admin      |  :push_tag                      | true
        :admin      |  :push_new_tag                  | true
        :admin      |  :push_all                      | true
        :admin      |  :merge_into_protected_branch   | true
        :maintainer |  :any                           | true
        :maintainer |  :push_new_branch               | true
        :maintainer |  :push_master                   | true
        :maintainer |  :push_protected_branch         | true
        :maintainer |  :push_remove_protected_branch  | false
        :maintainer |  :push_tag                      | true
        :maintainer |  :push_new_tag                  | true
        :maintainer |  :push_all                      | true
        :maintainer |  :merge_into_protected_branch   | true
        :developer  |  :any                           | true
        :developer  |  :push_new_branch               | true
        :developer  |  :push_master                   | true
        :developer  |  :push_protected_branch         | false
        :developer  |  :push_remove_protected_branch  | false
        :developer  |  :push_tag                      | true
        :developer  |  :push_new_tag                  | true
        :developer  |  :push_all                      | false
        :developer  |  :merge_into_protected_branch   | false
        :reporter   |  :any                           | false
        :reporter   |  :push_new_branch               | false
        :reporter   |  :push_master                   | false
        :reporter   |  :push_protected_branch         | false
        :reporter   |  :push_remove_protected_branch  | false
        :reporter   |  :push_tag                      | false
        :reporter   |  :push_new_tag                  | false
        :reporter   |  :push_all                      | false
        :reporter   |  :merge_into_protected_branch   | false
        :guest      |  :any                           | false
        :guest      |  :push_new_branch               | false
        :guest      |  :push_master                   | false
        :guest      |  :push_protected_branch         | false
        :guest      |  :push_remove_protected_branch  | false
        :guest      |  :push_tag                      | false
        :guest      |  :push_new_tag                  | false
        :guest      |  :push_all                      | false
        :guest      |  :merge_into_protected_branch   | false
      end

      with_them do
        before do
          if role == :admin
            user.update_attribute(:admin, true)
            project.add_guest(user)
          else
            project.add_role(user, role)
          end

          protected_branch.save!
        end

        let(:allowed) do
          custom = custom_allowed.dig(role, action)
          custom.nil? ? base_allowed : custom
        end

        it 'has the correct permissions', :aggregate_failures do
          if allowed
            expect { push_access_check }.not_to raise_error
          else
            expect { push_access_check }.to raise_error(Gitlab::GitAccess::ForbiddenError)
          end
        end
      end
    end

    context 'there is a protected branch' do
      where(:protected_branch_name, :branch_rules, :merge_request_state) do
        names = ['feature', 'feat*']
        branch_rules_values = [
          [:maintainers_can_push],
          [:developers_can_push],
          [:developers_can_push, :developers_can_merge],
          [:no_one_can_push, :no_one_can_merge]
        ]
        merge_request_states = %i[none in_progress not_in_progress]

        names.flat_map do |name|
          branch_rules_values.flat_map do |branch_rules|
            merge_request_states.map { |state| [name, branch_rules, state] }
          end
        end
      end

      with_them do
        before do
          case merge_request_state
          when :in_progress
            # See: Gitlab::Checks::MatchingMergeRequest#match?
            merge_request.update!(
              state: 'locked',
              in_progress_merge_commit_sha: merge_into_protected_branch
            )
          when :not_in_progress
            merge_request.update!(in_progress_merge_commit_sha: nil)
          when :none
            merge_request.update!(target_branch: 'not-the-feature-branch')
          end
        end

        it_behaves_like 'protected branch checks' do
          let(:protected_branch) do
            create(:protected_branch, *branch_rules,
                   name: protected_branch_name, project: project)
          end

          let(:custom_allowed) do
            if branch_rules.include?(:no_one_can_push)
              cannot_push = push_protected_overrides(false)
              { developer: cannot_push, maintainer: cannot_push, admin: cannot_push }
            elsif branch_rules.include?(:developers_can_push)
              case merge_request_state
              when :none
                { developer: push_protected_overrides(true) }
              when :in_progress
                { developer: { merge_into_protected_branch: true } }
              when :not_in_progress
                { developer: { merge_into_protected_branch: branch_rules.include?(:developers_can_merge) } }
              end
            else
              {}
            end
          end
        end

        def push_protected_overrides(ok = false)
          { push_protected_branch: ok, push_all: ok, merge_into_protected_branch: ok }
        end
      end
    end

    context 'when pushing to a project' do
      let(:project) { create(:project, :public, :repository) }
      let(:changes) { "#{Gitlab::Git::BLANK_SHA} 570e7b2ab refs/heads/wow" }

      before do
        project.add_developer(user)
      end

      it 'does not allow deactivated users to push' do
        user.deactivate!

        expect { push_access_check }.to raise_forbidden("Your account has been deactivated by your administrator. Please log back in from a web browser to reactivate your account at #{Gitlab.config.gitlab.url}")
      end

      it 'cleans up the files' do
        expect(project.repository).to receive(:clean_stale_repository_files).and_call_original
        expect { push_access_check }.not_to raise_error
      end

      it 'avoids N+1 queries', :request_store do
        # Run this once to establish a baseline. Cached queries should get
        # cached, so that when we introduce another change we shouldn't see
        # additional queries.
        access.check('git-receive-pack', changes)

        control_count = ActiveRecord::QueryRecorder.new do
          access.check('git-receive-pack', changes)
        end

        changes = ['6f6d7e7ed 570e7b2ab refs/heads/master', '6f6d7e7ed 570e7b2ab refs/heads/feature']

        # There is still an N+1 query with protected branches
        expect { access.check('git-receive-pack', changes) }.not_to exceed_query_limit(control_count).with_threshold(2)
      end

      it 'raises TimeoutError when #check_single_change_access raises a timeout error' do
        message = "Push operation timed out\n\nTiming information for debugging purposes:\nRunning checks for ref: wow"

        expect_next_instance_of(Gitlab::Checks::ChangeAccess) do |check|
          expect(check).to receive(:validate!).and_raise(Gitlab::Checks::TimedLogger::TimeoutError)
        end

        expect { access.check('git-receive-pack', changes) }.to raise_error(described_class::TimeoutError, message)
      end
    end
  end

  describe '#check_project_accessibility!' do
    context 'when the project is nil' do
      let(:container) { nil }
      let(:project_path) { "new-project" }

      context 'when user is allowed to create project in namespace' do
        let(:namespace_path) { user.namespace.path }

        it 'blocks pull access with "not found"' do
          expect { pull_access_check }.to raise_not_found
        end

        it 'allows push access' do
          expect { push_access_check }.not_to raise_error
        end
      end

      context 'when user is not allowed to create project in namespace' do
        let(:user2) { create(:user) }
        let(:namespace_path) { user2.namespace.path }

        it 'blocks push and pull with "not found"' do
          aggregate_failures do
            expect { pull_access_check }.to raise_not_found
            expect { push_access_check }.to raise_not_found
          end
        end
      end
    end
  end

  describe '#ensure_project_on_push!' do
    before do
      allow(access).to receive(:changes).and_return(changes)
    end

    shared_examples 'no project is created' do
      let(:raise_specific_error) { raise_not_found }
      let(:action) { push_access_check }

      it 'does not create a new project' do
        expect { action }
          .to raise_specific_error
          .and change { Project.count }.by(0)
      end
    end

    context 'when push' do
      let(:cmd) { 'git-receive-pack' }

      context 'when project does not exist' do
        let(:project_path) { "nonexistent" }
        let(:container) { nil }

        context 'when changes is _any' do
          let(:changes) { Gitlab::GitAccess::ANY }

          context 'when authentication abilities include push code' do
            let(:authentication_abilities) { [:push_code] }

            context 'when user can create project in namespace' do
              let(:namespace_path) { user.namespace.path }

              it 'creates a new project in the correct namespace' do
                expect { push_access_check }
                  .to change { Project.count }.by(1)
                  .and change { Project.where(namespace: user.namespace, name: project_path).count }.by(1)
              end
            end

            context 'when user cannot create project in namespace' do
              let(:user2) { create(:user) }
              let(:namespace_path) { user2.namespace.path }

              it_behaves_like 'no project is created'
            end
          end

          context 'when authentication abilities do not include push code' do
            let(:authentication_abilities) { [] }

            context 'when user can create project in namespace' do
              let(:namespace_path) { user.namespace.path }

              it_behaves_like 'no project is created' do
                let(:raise_specific_error) { raise_forbidden }
              end
            end
          end
        end

        context 'when check contains actual changes' do
          let(:changes) { "#{Gitlab::Git::BLANK_SHA} 570e7b2abdd848b95f2f578043fc23bd6f6fd24d refs/heads/new_branch" }

          it_behaves_like 'no project is created'
        end
      end

      context 'when project exists' do
        let(:changes) { Gitlab::GitAccess::ANY }
        let!(:container) { project }

        it_behaves_like 'no project is created'
      end

      context 'when deploy key is used' do
        let(:key) { create(:deploy_key, user: user) }
        let(:actor) { key }
        let(:project_path) { "nonexistent" }
        let(:container) { nil }
        let(:namespace_path) { user.namespace.path }
        let(:changes) { Gitlab::GitAccess::ANY }

        it_behaves_like 'no project is created'
      end
    end

    context 'when pull' do
      let(:cmd) { 'git-upload-pack' }
      let(:changes) { Gitlab::GitAccess::ANY }

      context 'when project does not exist' do
        let(:project_path) { "new-project" }
        let(:namespace_path) { user.namespace.path }
        let(:container) { nil }

        it_behaves_like 'no project is created' do
          let(:action)  { pull_access_check }
        end
      end
    end
  end

  def raise_not_found
    raise_error(Gitlab::GitAccess::NotFoundError, Gitlab::GitAccess::ERROR_MESSAGES[:project_not_found])
  end

  def raise_forbidden(msg = be_present)
    raise_error(Gitlab::GitAccess::ForbiddenError, msg)
  end

  def raise_namespace_not_found
    raise_error(Gitlab::GitAccess::NotFoundError, described_class::ERROR_MESSAGES[:namespace_not_found])
  end
end
