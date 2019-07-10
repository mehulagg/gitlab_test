# frozen_string_literal: true

require 'spec_helper'

describe 'User updates feature flag', :js do
  include FeatureFlagHelpers

  let(:user) { create(:user) }
  let(:project) { create(:project, namespace: user.namespace) }

  let!(:feature_flag) do
    create_flag(project, 'ci_live_trace', false,
                description: 'For live trace feature')
  end

  let!(:scope) { create_scope(feature_flag, 'review/*', true) }

  def visit_edit_page
    visit(edit_project_feature_flag_path(project, feature_flag))
  end

  before do
    project.add_developer(user)
    stub_licensed_features(feature_flags: true)
    sign_in(user)
  end

  it 'user sees persisted default scope' do
    visit_edit_page

    within_scope_row(1) do
      within_environment_spec do
        expect(page).to have_content('* (All Environments)')
      end

      within_status do
        expect(find('.project-feature-toggle')['aria-label'])
          .to eq('Toggle Status: OFF')
      end
    end
  end

  context 'when user updates a status of a scope' do
    before do
      visit_edit_page

      within_scope_row(2) do
        within_status { find('.project-feature-toggle').click }
      end

      click_button 'Save changes'
      expect(page).to have_current_path(project_feature_flags_path(project))
    end

    it 'shows the updated feature flag' do
      within_feature_flag_row(1) do
        expect(page.find('.feature-flag-name')).to have_content('ci_live_trace')
        expect(page).to have_css('.js-feature-flag-status .badge-danger')

        within_feature_flag_scopes do
          expect(page.find('.badge:nth-child(1)')).to have_content('*')
          expect(page.find('.badge:nth-child(1)')['class']).to include('badge-inactive')
          expect(page.find('.badge:nth-child(2)')).to have_content('review/*')
          expect(page.find('.badge:nth-child(2)')['class']).to include('badge-inactive')
        end
      end
    end

    it 'records audit event' do
      visit(project_audit_events_path(project))

      expect(page).to(
        have_text("Updated feature flag ci live trace. Updated rule review/* active state from true to false.")
      )
    end
  end

  context 'when production environment is protected' do
    before do
      stub_licensed_features(protected_environments: true, feature_flags: true)
    end

    let!(:production_scope) do
      create_scope(feature_flag, 'production', true)
    end

    context 'when user has access to production environment' do
      before do
        create(:protected_environment, name: 'production', project: project, authorize_user_to_deploy: user)
      end

      it 'shows protected budge and allow user to edit scope' do
        visit_edit_page

        within_feature_flag_row(3) do
          expect(page).to have_content("Protected")
        end
      end
    end

    context 'when user does not have access to production environemnt' do
      before do
        create(:protected_environment, name: 'production', project: project, authorize_user_to_deploy: user)
      end

      it 'shows protected budge and does not allow user to edit scope' do
        visit_edit_page

        within_feature_flag_row(3) do
          expect(page).to have_content("Protected")
        end
      end
    end
  end

  context 'when user adds a new scope' do
    before do
      visit_edit_page

      within_scope_row(3) do
        within_environment_spec do
          find('.js-env-input').set('production')
          find('.js-create-button').click
        end
      end

      click_button 'Save changes'
      expect(page).to have_current_path(project_feature_flags_path(project))
    end

    it 'shows the newly created scope' do
      within_feature_flag_row(1) do
        within_feature_flag_scopes do
          expect(page.find('.badge:nth-child(3)')).to have_content('production')
          expect(page.find('.badge:nth-child(3)')['class']).to include('badge-inactive')
        end
      end
    end

    it 'records audit event' do
      visit(project_audit_events_path(project))

      expect(page).to(
        have_text("Updated feature flag ci live trace")
      )
    end
  end

  context 'when user deletes a scope' do
    before do
      visit_edit_page

      within_scope_row(2) do
        within_delete { find('.js-delete-scope').click }
      end

      click_button 'Save changes'
      expect(page).to have_current_path(project_feature_flags_path(project))
    end

    it 'shows the updated feature flag' do
      within_feature_flag_row(1) do
        within_feature_flag_scopes do
          expect(page).to have_css('.badge:nth-child(1)')
          expect(page).not_to have_css('.badge:nth-child(2)')
        end
      end
    end

    it 'records audit event' do
      visit(project_audit_events_path(project))

      expect(page).to(
        have_text("Updated feature flag ci live trace")
      )
    end
  end
end
