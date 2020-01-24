# frozen_string_literal: true

require 'spec_helper'

describe 'Blob button line permalinks (BlobLinePermalinkUpdater)', :js do
  include TreeHelper

  let(:project) { create(:project, :public, :repository) }
  let(:path) { 'CHANGELOG' }
  let(:sha) { project.repository.commit.sha }

  describe 'On a file(blob)' do
    def visit_blob(fragment = nil)
      visit project_blob_path(project, tree_join('master', path), anchor: fragment)
    end

    describe 'Click "Permalink" button' do
      it 'works with no initial line number fragment hash' do
        visit_blob

        href = project_blob_path(project, tree_join(sha, path))

        expect(page).to have_css(".js-data-file-blob-permalink-url[href='#{href}']")
      end

      it 'maintains intitial fragment hash' do
        fragment = "L3"

        visit_blob(fragment)

        href = project_blob_path(project, tree_join(sha, path), anchor: fragment)

        expect(page).to have_css(".js-data-file-blob-permalink-url[href='#{href}']")
      end

      it 'changes fragment hash if line number clicked' do
        ending_fragment = "L5"

        visit_blob

        find('#L3').click
        find("##{ending_fragment}").click

        href = project_blob_path(project, tree_join(sha, path), anchor: ending_fragment)

        expect(page).to have_css(".js-data-file-blob-permalink-url[href='#{href}']")
      end

      it 'with initial fragment hash, changes fragment hash if line number clicked' do
        fragment = "L1"
        ending_fragment = "L5"

        visit_blob(fragment)

        find('#L3').click
        find("##{ending_fragment}").click

        href = project_blob_path(project, tree_join(sha, path), anchor: ending_fragment)

        expect(page).to have_css(".js-data-file-blob-permalink-url[href='#{href}']")
      end
    end

    describe 'Click "Blame" button' do
      it 'works with no initial line number fragment hash' do
        visit_blob

        href = project_blame_path(project, tree_join('master', path))

        expect(page).to have_css(".js-blob-blame-link[href='#{href}']")
      end

      it 'maintains intitial fragment hash' do
        fragment = "L3"

        visit_blob(fragment)

        href = project_blame_path(project, tree_join('master', path), anchor: fragment)

        expect(page).to have_css(".js-blob-blame-link[href='#{href}']")
      end

      it 'changes fragment hash if line number clicked' do
        ending_fragment = "L5"

        visit_blob

        find('#L3').click
        find("##{ending_fragment}").click

        href = project_blame_path(project, tree_join('master', path), anchor: ending_fragment)

        expect(page).to have_css(".js-blob-blame-link[href='#{href}']")
      end

      it 'with initial fragment hash, changes fragment hash if line number clicked' do
        fragment = "L1"
        ending_fragment = "L5"

        visit_blob(fragment)

        find('#L3').click
        find("##{ending_fragment}").click

        href = project_blame_path(project, tree_join('master', path), anchor: ending_fragment)

        expect(page).to have_css(".js-blob-blame-link[href='#{href}']")
      end
    end
  end
end
