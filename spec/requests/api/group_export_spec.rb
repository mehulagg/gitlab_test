# frozen_string_literal: true

require 'spec_helper'

describe API::GroupExport do
  set(:group) { create(:group) }
  set(:user) { create(:user) }
  set(:admin) { create(:admin) }

  let(:path) { "/groups/#{group.id}/export" }
  let(:download_path) { "/groups/#{group.id}/export/download" }

  let(:export_path) { "#{Dir.tmpdir}/group_export_spec" }

  before do
    allow_any_instance_of(Gitlab::ImportExport).to receive(:storage_path).and_return(export_path)
  end

  after do
    FileUtils.rm_rf(export_path, secure: true)
  end

  describe 'GET /groups/:group_id/export/download' do
    let(:user) { admin }

    before do
      stub_uploads_object_storage(ImportExportUploader)

      group.add_maintainer(user)

      upload = ImportExportUpload.new(group: group)
      upload.export_file = fixture_file_upload('spec/fixtures/group_export.tar.gz', "`/tar.gz")
      upload.save!
    end

    it 'downloads exported group archive' do
      get api(download_path, user)

      expect(response).to have_gitlab_http_status(200)
    end
  end

  describe 'POST /groups/:group_id/export' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'accepts download' do
        post api(path, user)

        expect(response).to have_gitlab_http_status(202)
      end
    end

    context 'when user is not admin' do
      before do
        group.add_developer(user)
      end

      it 'forbids the request' do
        post api(path, user)

        expect(response).to have_gitlab_http_status(403)
      end
    end
  end
end
