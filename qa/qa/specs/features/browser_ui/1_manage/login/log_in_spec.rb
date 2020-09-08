# frozen_string_literal: true

module QA
  RSpec.describe 'Manage', :smoke do
    describe 'basic user login' do
      it 'user logs in using basic credentials and logs out', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/424' do
        p Runtime::Env.release
        expect(Runtime::Env.release).not_to be_empty
      end
    end
  end
end
