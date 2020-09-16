# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::IssueSidebarBasicEntity do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository) }
  let(:issue) { create(:issue, project: project, assignees: [user]) }

  subject do
    serializer = IssueSerializer.new(current_user: user, project: project)
    serializer.represent(issue, serializer: 'sidebar')
  end

  tests = [
    {
      conf: { request_cve_enabled: true, maintainer: true, confidential: true },
      expect: { request_cve_enabled: true }
    },
    {
      conf: { request_cve_enabled: false, maintainer: true, confidential: true },
      expect: { request_cve_enabled: false }
    },
    {
      conf: { request_cve_enabled: true, maintainer: false, confidential: true },
      expect: { request_cve_enabled: false }
    },
    {
      conf: { request_cve_enabled: true, maintainer: true, confidential: false },
      expect: { request_cve_enabled: false }
    }
  ]
  tests.each do |test|
    test_conf = test[:conf]
    test_expect = test[:expect]

    context "When serializing" do
      before do
        allow_any_instance_of(EE::ProjectsHelper).to receive(:request_cve_enabled?).and_return(test_conf[:request_cve_enabled])
        issue.confidential = test_conf[:confidential]
        issue.save!
        project.add_maintainer(user) if test_conf[:maintainer]
      end

      desc = test_conf[:request_cve_enabled] ? '' : 'not '
      context "with CVE Requests #{desc}enabled for the project," do
        desc = test_conf[:maintainer] ? '' : 'not '
        context "the current user is #{desc}a maintainer," do
          desc = test_conf[:confidential] ? '' : 'not '
          context "the current issue is #{desc}confidential," do
            desc = test_expect[:request_cve_enabled] ? 'enabled' : 'disabled'
            it "reports CVE requests as #{desc}" do
              expect(subject[:request_cve_enabled]).to equal(test_expect[:request_cve_enabled])
            end
          end
        end
      end
    end
  end
end
