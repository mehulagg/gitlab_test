# frozen_string_literal: true

require 'spec_helper'

describe UsersStatistic do
  subject { build(:users_statistic) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:as_at) }
  end
end
