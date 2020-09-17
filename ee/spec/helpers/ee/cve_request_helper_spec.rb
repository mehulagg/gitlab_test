# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::CveRequestHelper do
  let(:project) { create(:project) }

  describe '#request_cve_enabled_for_issue_and_user?' do
    opts = {
      maintainer: [true, false],
      confidential: [true, false],
      request_cve_enabled: [true, false]
    }
    opts[:maintainer].product(opts[:confidential], opts[:request_cve_enabled]) do |settings|
      maintainer, confidential, request_cve_enabled = settings
      context "with settings: maintainer: #{maintainer}, confidential: #{confidential}, enabled: #{request_cve_enabled}" do
        let(:user) { create_user(maintainer ? :maintainer : :developer) }
        let(:issue) do
          create(:issue, project: project, assignees: [user], confidential: confidential)
        end

        before do
          allow(helper).to receive(:can?) do |_user, perm, project|
            perm == :admin_project ? maintainer : false
          end
          allow(helper).to receive(:request_cve_enabled?).and_return(request_cve_enabled)
        end

        expected = maintainer && confidential && request_cve_enabled
        it "returns #{expected}" do
          res = helper.request_cve_enabled_for_issue_and_user?(issue, user)
          expect(res).to equal(expected)
        end
      end
    end
  end

  describe '#request_cve_enabled?' do
    opts = {
      gitlab_com: [true, false],
      setting_enabled: [true, false],
      visibility: [:PUBLIC, :INTERNAL, :PRIVATE]
    }
    opts[:gitlab_com].product(opts[:setting_enabled], opts[:visibility]) do |settings|
      gitlab_com, setting_enabled, visibility = settings
      context "GitLab.com: #{gitlab_com}, setting_enabled: #{setting_enabled}, visibility: #{visibility}" do
        before do
          allow(::Gitlab).to receive(:com?).and_return(gitlab_com)
          vis_val = Gitlab::VisibilityLevel.const_get(visibility, false)
          project.visibility_level = vis_val
          project.save!

          security_setting = ProjectSecuritySetting.safe_find_or_create_for(project)
          security_setting.cve_id_request_enabled = setting_enabled
          security_setting.save!
        end

        expected = gitlab_com && setting_enabled && visibility == :PUBLIC
        it "returns #{expected}" do
          expect(helper.request_cve_enabled?(project)).to equal(expected)
        end
      end
    end
  end

  def create_user(access_level_trait)
    user = create(:user)
    create(:project_member, access_level_trait, user: user, project: project)
    user
  end
end
