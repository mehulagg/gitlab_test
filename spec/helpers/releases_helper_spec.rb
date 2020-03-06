# frozen_string_literal: true

require 'spec_helper'

describe ReleasesHelper do
  describe '#illustration' do
    it 'returns the correct image path' do
      expect(helper.illustration).to match(/illustrations\/releases-(\w+)\.svg/)
    end
  end

  describe '#help_page' do
    it 'returns the correct link to the help page' do
      expect(helper.help_page).to include('user/project/releases/index')
    end
  end

  context 'url helpers' do
    let(:project) { build(:project, namespace: create(:group)) }
    let(:release) { create(:release, project: project) }
    let(:user) { create(:user) }

    before do
      helper.instance_variable_set(:@project, project)
      helper.instance_variable_set(:@release, release)
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:can?)
                    .with(user, :create_release, project)
                    .and_return(false)
    end

    describe '#data_for_releases_page' do
      shared_examples 'includes all required keys' do
        it 'includes the required data for displaying release blocks' do
          expect(helper.data_for_releases_page.keys).to include(
            :project_id,
            :illustration_path,
            :documentation_path
          )
        end
      end

      context 'when the user is not allowed to create a new release' do
        it_behaves_like 'includes all required keys'

        it 'does not include new_release_path' do
          expect(helper.data_for_releases_page).not_to include(:new_release_path)
        end
      end

      context 'when the user is allowed to create a new release' do
        before do
          allow(helper).to receive(:can?)
                       .with(user, :create_release, project)
                       .and_return(true)
        end

        it_behaves_like 'includes all required keys'

        it 'includes new_release_path' do
          expect(helper.data_for_releases_page[:new_release_path]).to eq(new_project_tag_path(project))
        end
      end
    end

    describe '#data_for_edit_release_page' do
      it 'has the needed data to display the "edit release" page' do
        keys = %i(project_id
                  tag_name
                  markdown_preview_path
                  markdown_docs_path
                  releases_page_path
                  update_release_api_docs_path)
        expect(helper.data_for_edit_release_page.keys).to eq(keys)
      end
    end
  end
end
