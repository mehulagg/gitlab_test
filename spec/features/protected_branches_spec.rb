# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Protected Branches', :js do
  include ProtectedBranchHelpers

  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:project) { create(:project, :repository) }

  before do
    stub_feature_flags(deploy_keys_on_protected_branches: false)
  end

  context 'logged in as developer' do
    before do
      project.add_developer(user)
      sign_in(user)
    end

    describe 'Delete protected branch' do
      before do
        create(:protected_branch, project: project, name: 'fix')
        expect(ProtectedBranch.count).to eq(1)
      end

      it 'does not allow developer to removes protected branch' do
        visit project_branches_path(project)

        fill_in 'branch-search', with: 'fix'
        find('#branch-search').native.send_keys(:enter)

        expect(page).to have_css('.btn-remove.disabled')
      end
    end
  end

  context 'logged in as maintainer' do
    before do
      project.add_maintainer(user)
      sign_in(user)
    end

    describe 'Delete protected branch' do
      before do
        create(:protected_branch, project: project, name: 'fix')
        expect(ProtectedBranch.count).to eq(1)
      end

      it 'removes branch after modal confirmation' do
        visit project_branches_path(project)

        fill_in 'branch-search', with: 'fix'
        find('#branch-search').native.send_keys(:enter)

        expect(page).to have_content('fix')
        expect(find('.all-branches')).to have_selector('li', count: 1)
        page.find('[data-target="#modal-delete-branch"]').click

        expect(page).to have_css('.js-delete-branch[disabled]')
        fill_in 'delete_branch_input', with: 'fix'
        click_link 'Delete protected branch'

        fill_in 'branch-search', with: 'fix'
        find('#branch-search').native.send_keys(:enter)

        expect(page).to have_content('No branches to show')
      end
    end
  end

  context 'logged in as admin' do
    before do
      sign_in(admin)
    end

    describe "explicit protected branches" do
      it "allows creating explicit protected branches" do
        visit project_protected_branches_path(project)
        set_defaults
        set_protected_branch_name('some-branch')
        click_on "Protect"

        within(".protected-branches-list") { expect(page).to have_content('some-branch') }
        expect(ProtectedBranch.count).to eq(1)
        expect(ProtectedBranch.last.name).to eq('some-branch')
      end

      it "displays the last commit on the matching branch if it exists" do
        commit = create(:commit, project: project)
        project.repository.add_branch(admin, 'some-branch', commit.id)

        visit project_protected_branches_path(project)
        set_defaults
        set_protected_branch_name('some-branch')
        click_on "Protect"

        within(".protected-branches-list") do
          expect(page).not_to have_content("matching")
          expect(page).not_to have_content("was deleted")
        end
      end

      it "displays an error message if the named branch does not exist" do
        visit project_protected_branches_path(project)
        set_defaults
        set_protected_branch_name('some-branch')
        click_on "Protect"

        within(".protected-branches-list") { expect(page).to have_content('Branch was deleted') }
      end
    end

    describe "wildcard protected branches" do
      it "allows creating protected branches with a wildcard" do
        visit project_protected_branches_path(project)
        set_defaults
        set_protected_branch_name('*-stable')
        click_on "Protect"

        within(".protected-branches-list") { expect(page).to have_content('*-stable') }
        expect(ProtectedBranch.count).to eq(1)
        expect(ProtectedBranch.last.name).to eq('*-stable')
      end

      it "displays the number of matching branches" do
        project.repository.add_branch(admin, 'production-stable', 'master')
        project.repository.add_branch(admin, 'staging-stable', 'master')

        visit project_protected_branches_path(project)
        set_defaults
        set_protected_branch_name('*-stable')
        click_on "Protect"

        within(".protected-branches-list") do
          expect(page).to have_content("2 matching branches")
        end
      end

      it "displays all the branches matching the wildcard" do
        project.repository.add_branch(admin, 'production-stable', 'master')
        project.repository.add_branch(admin, 'staging-stable', 'master')
        project.repository.add_branch(admin, 'development', 'master')

        visit project_protected_branches_path(project)
        set_protected_branch_name('*-stable')
        set_defaults
        click_on "Protect"

        visit project_protected_branches_path(project)
        click_on "2 matching branches"

        within(".protected-branches-list") do
          expect(page).to have_content("production-stable")
          expect(page).to have_content("staging-stable")
          expect(page).not_to have_content("development")
        end
      end
    end

    describe "access control" do
      before do
        stub_licensed_features(protected_refs_for_users: false)
      end

      include_examples "protected branches > access control > CE"
    end
  end

  RSpec.shared_examples 'when the deploy_keys_on_protected_branches FF is turned on' do
    before do
      stub_feature_flags(deploy_keys_on_protected_branches: true)
      project.add_maintainer(user)
      sign_in(user)
    end

    context 'when deploy keys are enabled to this project' do
      let!(:deploy_key_1) { create(:deploy_key, title: 'title 1', projects: [project]) }
      let!(:deploy_key_2) { create(:deploy_key, title: 'title 2', projects: [project]) }

      context 'when only one deploy key can push' do
        before do
          deploy_key_1.deploy_keys_projects.first.update!(can_push: true)
        end

        it 'shows roles, users and deploy keys section in the "Allowed to push" main dropdown, with only one deploy key' do
          visit project_protected_branches_path(project)

          find(".js-allowed-to-push").click
          wait_for_requests

          within('.qa-allowed-to-push-dropdown') do
            dropdown_headers = page.all('.dropdown-header').map(&:text)

            expect(dropdown_headers).to contain_exactly(*all_dropdown_sections)
            expect(page).to have_content('title 1')
            expect(page).not_to have_content('title 2')
          end
        end

        it 'shows only roles and users in the "Allowed to merge" main dropdown' do
          visit project_protected_branches_path(project)

          find(".js-allowed-to-merge").click
          wait_for_requests

          within('.qa-allowed-to-merge-dropdown') do
            dropdown_headers = page.all('.dropdown-header').map(&:text)

            expect(dropdown_headers).to contain_exactly(*dropdown_sections_minus_deploy_keys)
          end
        end

        it 'shows roles, users and deploy keys in the "Allowed to push" update dropdown' do
          create(:protected_branch, :no_one_can_push, project: project, name: 'master')

          visit project_protected_branches_path(project)

          within(".js-protected-branch-edit-form") do
            find(".js-allowed-to-push").click
            wait_for_requests

            dropdown_headers = page.all('.dropdown-header').map(&:text)

            expect(dropdown_headers).to contain_exactly(*all_dropdown_sections)
          end
        end
      end

      context 'when no deploy key can push' do
        it 'just shows roles, users sections in the "Allowed to push" dropdown' do
          visit project_protected_branches_path(project)

          find(".js-allowed-to-push").click
          wait_for_requests

          within('.qa-allowed-to-push-dropdown') do
            dropdown_headers = page.all('.dropdown-header').map(&:text)

            expect(dropdown_headers).to contain_exactly(*dropdown_sections_minus_deploy_keys)
          end
        end

        it 'just shows roles, users in the "Allowed to push" update dropdown' do
          create(:protected_branch, :no_one_can_push, project: project, name: 'master')

          visit project_protected_branches_path(project)

          within(".js-protected-branch-edit-form") do
            find(".js-allowed-to-push").click
            wait_for_requests

            dropdown_headers = page.all('.dropdown-header').map(&:text)

            expect(dropdown_headers).to contain_exactly(*dropdown_sections_minus_deploy_keys)
          end
        end
      end
    end
  end

  context 'when the users for protected branches feature is on' do
    before do
      stub_licensed_features(protected_refs_for_users: true)
    end

    include_examples 'when the deploy_keys_on_protected_branches FF is turned on' do
      let(:all_dropdown_sections) { %w(Roles Users Deploy\ Keys) }
      let(:dropdown_sections_minus_deploy_keys) { %w(Roles Users) }
    end
  end

  context 'when the users for protected branches feature is off' do
    before do
      stub_licensed_features(protected_refs_for_users: false)
    end

    include_examples 'when the deploy_keys_on_protected_branches FF is turned on' do
      let(:all_dropdown_sections) { %w(Roles Deploy\ Keys) }
      let(:dropdown_sections_minus_deploy_keys) { %w(Roles) }
    end
  end
end
