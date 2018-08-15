require 'spec_helper'

describe Gitlab::GroupSearchResults do
  let(:user) { create(:user) }

  describe 'user search' do
    let(:group) { create(:group) }

    it 'returns the users belonging to the group matching the search query' do
      user1 = create(:user, username: 'gob_bluth')
      create(:group_member, :developer, user: user1, group: group)

      user2 = create(:user, username: 'michael_bluth')
      create(:group_member, :developer, user: user2, group: group)

      create(:user, username: 'gob_2018')

      expect(described_class.new(user, anything, group, 'gob').objects('users')).to eq [user1]
    end

    it 'returns the user belonging to the subgroup matching the search query', :nested_groups do
      user1 = create(:user, username: 'gob_bluth')
      subgroup = create(:group, parent: group)
      create(:group_member, :developer, user: user1, group: subgroup)

      create(:user, username: 'gob_2018')

      expect(described_class.new(user, anything, group, 'gob').objects('users')).to eq [user1]
    end
  end
end
