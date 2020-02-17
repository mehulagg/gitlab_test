# frozen_string_literal: true

require 'spec_helper'

describe Member, type: :model do
  describe '.roles_stats' do
    before do
      project1 = create(:project_empty_repo) # user #1; maintainer: 1
      project1.add_reporter(create(:user)) # user #2; reporter: 1

      project2 = create(:project_empty_repo) # user #3; maintainer: 2
      project2.add_developer(create(:user)) # user #4; developer: 1

      group1 = create(:group)
      group1.add_developer(create(:user)) # user #5; developer: 2

      group2 = create(:group)
      project2.add_reporter(create(:user)) # user #6; reporter: 2

      # Add same user as Reporter and Developer to different projects
      # and as a Reporter to a group
      # and expect it to be counted once as a developer for the stats
      user1 = create(:user) # user #7
      project1.add_reporter(user1)
      project2.add_developer(user1) # developer: 3
      group1.add_guest(user1)

      # Add same user as Guest and Reporter to different groups
      # and as a Reporter to a project
      # and expect it to be counted once as a developer for the stats
      user2 = create(:user) # user #8
      group1.add_guest(user2)
      group2.add_reporter(user2) # reporter: 3
      project1.add_reporter(user2)
    end

    subject { described_class.roles_stats }

    it 'returns how many users have which role as the highest role' do
      expect(subject).to eq(
        Gitlab::Access::REPORTER => 3,
        Gitlab::Access::DEVELOPER => 3,
        Gitlab::Access::MAINTAINER => 2
      )
    end
  end

  describe '#notification_service' do
    it 'returns a NullNotificationService instance for LDAP users' do
      member = described_class.new

      allow(member).to receive(:ldap).and_return(true)

      expect(member.__send__(:notification_service))
        .to be_instance_of(::EE::NullNotificationService)
    end
  end
end
