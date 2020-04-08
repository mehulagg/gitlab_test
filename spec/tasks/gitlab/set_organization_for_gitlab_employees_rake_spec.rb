# frozen_string_literal: true

require 'rake_helper'

describe 'gitlab:set_organization_for_gitlab_employees rake task' do
  it 'sets organization field of GitLab employees to GitLab' do
    Rake.application.rake_require 'tasks/gitlab/set_organization_for_gitlab_employees'

    user1 = create(:user, email: 'bumblebee@gitlab.com', organization: 'GitLab')
    user2 = create(:user, email: 'sam@notgitlab.com', organization: nil)
    user3 = create(:user, email: 'volpina@gitlab.com', confirmed_at: nil, organization: nil)
    user4 = create(:user, email: 'drago@gitlab.com', confirmed_at: DateTime.now)
    user5 = create(:user, email: 'wolf@gitlab.com', confirmed_at: DateTime.now)

    # Set the organization bypassing the ActiveRecord callback
    user4.update_column(:organization, nil)
    user5.update_column(:organization, 'Something')

    expect do
      run_rake_task('gitlab:set_organization_for_gitlab_employees')
    end.to change { user4.reload[:organization] }.from(nil).to('GitLab')
      .and change { user5.reload[:organization] }.from('Something').to('GitLab')

    expect(user1.reload[:organization]).to eq('GitLab')
    expect(user2.reload[:organization]).to be_nil
    expect(user3.reload[:organization]).to be_nil
  end
end
